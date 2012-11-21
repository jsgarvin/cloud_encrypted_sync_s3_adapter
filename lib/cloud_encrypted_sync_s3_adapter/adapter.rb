require 'aws-sdk'

module CloudEncryptedSync
  module Adapters
    class S3 < Template

      def parse_command_line_options(opts,command_line_options)
        opts.on('--bucket BUCKETNAME', 'Name of S3 bucket to use.') do |bucket_name|
          command_line_options[:bucket] = bucket_name
        end
        opts.on('--s3-credentials ACCESS_KEY_ID,SECRET_ACCESS_KEY', Array, "Credentials for your S3 account." ) do| credentials|
          command_line_options[:s3_credentials] = credentials
        end
        return command_line_options
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

      def credentials
        Configuration.settings[:s3_credentials]
      end

      def connection
        @connection ||= AWS::S3.new(:access_key_id => credentials[0], :secret_access_key => credentials[1])
      end

      def bucket_name
        Configuration.settings[:bucket].to_sym
      end

      def bucket
        connection.buckets[bucket_name]
      end

    end
  end
end