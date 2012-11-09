require 'test_helper'

module CloudEncryptedSyncS3Adapter
  class AdapterTest < ActiveSupport::TestCase

    def setup
      if File.exist?(CloudEncryptedSync::Master.send(:config_file_path))
        @config = YAML.load_file(CloudEncryptedSync::Master.send(:config_file_path))
      end
      @test_bucket_name = "cloud_encrypted_sync_unit_test_bucket_#{Digest::SHA1.hexdigest(rand.to_s)}"
      CloudEncryptedSync::Master.instance_variable_set(:@command_line_options, CloudEncryptedSync::Master.instance_variable_get(:@command_line_options).merge({:bucket => @test_bucket_name, :s3_credentials => @config['s3_credentials']}))
      create_test_bucket
    end

    test 'should write readable data to s3 and then delete it' do

      skip 'S3 credentials for test bucket not provided.' unless credentials.is_a?(Array) and credentials != []

      test_data = 'testdata'
      test_key = 'testkey'

      assert !adapter.key_exists?(test_key)
      assert_difference('adapter.send(:bucket).objects.count') do
        adapter.write(test_data,test_key)
      end
      assert adapter.key_exists?(test_key)

      assert_equal(test_data,adapter.read(test_key))

      assert_difference('adapter.send(:bucket).objects.count',-1) do
        adapter.delete(test_key)
      end
      assert !adapter.key_exists?(test_key)

    end


    #######
    private
    #######

    def credentials
      @config['s3_credentials']
    end

    def create_test_bucket
      adapter.send(:connection).buckets.create(@test_bucket_name)
    end

    def delete_test_bucket
      adapter.send(:bucket).delete! unless credentials == [] or !credentials.is_a?(Array)
    end
  end
end