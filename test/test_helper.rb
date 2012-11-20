require 'rubygems'
require 'bundler/setup'
require 'simplecov'
require 'active_support/test_case'
require 'test/unit'
require 'etc'

SimpleCov.start

require 'cloud_encrypted_sync'
require 'cloud_encrypted_sync_s3_adapter'

module CloudEncryptedSyncS3Adapter
  class ActiveSupport::TestCase

    def adapter
      CloudEncryptedSync::Adapters::S3
    end

  end
end
require 'mocha'