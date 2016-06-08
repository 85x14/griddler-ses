require 'griddler'
require 'griddler/ses/version'
require 'griddler/ses/adapter'
require 'griddler/ses/middleware'
require 'griddler/ses/railtie'
require 'griddler/ses/config'
require 'griddler/ses/attachments_wrapper'
require 'griddler/ses/prepare_notification_params'

module Griddler
  module Ses
    def self.config(&block)
      @config ||= Griddler::Ses::Config.new
      block_given? ? yield(@config) : @config
    end
  end
end

Griddler.adapter_registry.register(:ses, Griddler::Ses::Adapter)
