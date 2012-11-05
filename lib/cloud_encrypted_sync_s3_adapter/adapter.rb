require 'aws-sdk'
require 'cloud_encrypted_sync'

module CloudEncryptedSync
  module Adapters
    class S3 < Template

      class << self

        def parse_command_line_options(opts)
          opts.on('--bucket BUCKETNAME', 'Name of S3 bucket to use.') do |bucket_name|
            command_line_options[:bucket] = bucket_name
          end
          opts.on('--s3-credentials ACCESS_KEY_ID,SECRET_ACCESS_KEY', Array, "Credentials for your S3 account." ) do| credentials|
            @command_line_options[:s3_credentials] = credentials
          end
        end

        def write(data, key)
          bucket.objects.create(key,data)
        end

        def read(key)
          bucket.objects[key].read
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
          config[:s3_credentials]
        end

        def connection
          @connection ||= AWS::S3.new(:access_key_id => credentials[0], :secret_access_key => credentials[1])
        end

        def bucket_name
          config[:bucket].to_sym
        end

        def bucket
          connection.buckets[bucket_name]
        end

      end
    end
  end
end