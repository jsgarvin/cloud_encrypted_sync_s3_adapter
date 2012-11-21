require 'aws-sdk'

module CloudEncryptedSync
  module Adapters
    class S3 < Template
      attr_accessor :bucket_name, :credentials

      def parse_command_line_options(parser)
        parser.on('--bucket BUCKETNAME', 'Name of S3 bucket to use.') do |bucket_argument|
          self.bucket_name = bucket_argument.to_sym
        end
        parser.on('--s3-credentials ACCESS_KEY_ID,SECRET_ACCESS_KEY', Array, "Credentials for your S3 account." ) do |credentials_argument|
          self.credentials = credentials_argument
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

      def connection
        @connection ||= AWS::S3.new(:access_key_id => credentials[0], :secret_access_key => credentials[1])
      end

      def bucket
        connection.buckets[bucket_name]
      end

    end
  end
end