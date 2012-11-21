require 'test_helper'

module CloudEncryptedSyncS3Adapter
  class AdapterTest < ActiveSupport::TestCase

    def setup
      if File.exist?(CloudEncryptedSync::Configuration.send(:config_file_path))
        @config = YAML.load_file(CloudEncryptedSync::Configuration.send(:config_file_path))
      end
      stub_configuration
      create_test_bucket
    end

    def teardown
      delete_test_bucket
    end

    test 'should parse command line options' do
      unstub_configuration
      Object.send(:remove_const,:ARGV)
      ::ARGV = '--bucket foobar --access-key-id KEY_ID --access-key ACCESS_KEY'.split(/\s/)
      @command_line_options = {}
      @option_parser = OptionParser.new do |parser|
        adapter.parse_command_line_options(parser)
      end
      @option_parser.parse!
      assert_equal('foobar',CloudEncryptedSync::Adapters::S3.instance.send(:bucket_name))
      assert_equal('KEY_ID',CloudEncryptedSync::Adapters::S3.instance.send(:access_key_id))
      assert_equal('ACCESS_KEY',CloudEncryptedSync::Adapters::S3.instance.send(:access_key))
      stub_configuration
    end

    test 'should write readable data to s3 and then delete it' do

      skip 'S3 credentials for test bucket not provided.' unless access_key and access_key_id

      test_data = 'testdata'
      test_key = 'testkey'

      assert !adapter.key_exists?(test_key)
      assert_difference('adapter.instance.send(:bucket).objects.count') do
        adapter.write(test_data,test_key)
      end
      assert adapter.key_exists?(test_key)

      assert_equal(test_data,adapter.read(test_key))

      assert_difference('adapter.instance.send(:bucket).objects.count',-1) do
        adapter.delete(test_key)
      end
      assert !adapter.key_exists?(test_key)

    end

    test 'should raise NoSuchKey error' do
      assert_raises(CloudEncryptedSync::Errors::NoSuchKey) { adapter.read('nonexistentkey') }
    end

    #######
    private
    #######

    def access_key
      @config['s3-access-key']
    end

    def access_key_id
      @config['s3-access-key-id']
    end

    def create_test_bucket
      adapter.instance.send(:connection).buckets.create(test_bucket_name)
    end

    def delete_test_bucket
      adapter.instance.send(:bucket).delete! if access_key and access_key_id
    end

    def test_bucket_name
      @test_bucket_name ||= "cloud_encrypted_sync_unit_test_bucket_#{Digest::SHA1.hexdigest(rand.to_s)}"
    end

    def stub_configuration
      CloudEncryptedSync::Configuration.stubs(:settings).returns(
        {
          :excryption_key => 'abc',
          :adapter => 's3',
          :sync_path => '/any/path',
        }
      )
      CloudEncryptedSync::Adapters::S3.any_instance.stubs(:bucket_name).returns(test_bucket_name)
      CloudEncryptedSync::Adapters::S3.any_instance.stubs(:access_key).returns(access_key)
      CloudEncryptedSync::Adapters::S3.any_instance.stubs(:access_key_id).returns(access_key_id)
    end

    def unstub_configuration
      CloudEncryptedSync::Configuration.unstub(:settings)
      CloudEncryptedSync::Adapters::S3.any_instance.unstub(:bucket_name)
      CloudEncryptedSync::Adapters::S3.any_instance.unstub(:access_key)
      CloudEncryptedSync::Adapters::S3.any_instance.unstub(:access_key_id)
    end
  end
end