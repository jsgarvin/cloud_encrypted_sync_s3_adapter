require 'aws-sdk'

module CloudEncryptedSync
  module Adapters
    class S3 < Template
      attr_writer :bucket_name, :access_key, :access_key_id

      def parse_command_line_options(parser)
        parser.on('--bucket BUCKETNAME', 'Name of S3 bucket to use.') do |bucket_argument|
          self.bucket_name = bucket_argument
        end
        parser.on('--access-key KEY', 'Access Key for S3 login.') do |bucket_argument|
          self.access_key = bucket_argument
        end
        parser.on('--access-key-id KEYID', 'Access Key ID for S3 login.') do |bucket_argument|
          self.access_key_id = bucket_argument
        end
      end

      def write(data, key)
        bucket.objects.create(key,data)
      end

      def read(key)
        begin
          bucket.objects[key].read
        rescue AWS::S3::Errors::NoSuchKey => exception
          raise CloudEncryptedSync::Errors::NoSuchKey.new(exception.message)
        end
      end

      def delete(key)
        bucket.objects[key].delete
      end

      def key_exists?(key)
        bucket.objects[key].exists?
      end

      #######
      private
      #######

      def bucket_name
        @bucket_name || Configuration.settings['s3-bucket']
      end

      def access_key
        @access_key || Configuration.settings['s3-access-key']
      end

      def access_key_id
        @access_key_id || Configuration.settings['s3-access-key-id']
      end

      def connection
        @connection ||= AWS::S3.new(:access_key_id => access_key_id, :secret_access_key => access_key)
      end

      def bucket
        connection.buckets[bucket_name]
      end

    end
  end
end