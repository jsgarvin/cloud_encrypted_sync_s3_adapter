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

    setup :preset_environment

    def preset_environment
      CloudEncryptedSync::Master.instance_variable_set(:@config,nil)
      CloudEncryptedSync::Master.instance_variable_set(:@command_line_options, {
        :data_dir => "#{Etc.getpwuid.dir}/.cloud_encrypted_sync"
      })
    end

    def adapter
      CloudEncryptedSync::Adapters::S3
    end
  end
end
require 'mocha'