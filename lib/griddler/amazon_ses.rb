require 'aws/sns_message'
require 'griddler'
require 'griddler/amazon_ses/version'
require 'griddler/amazon_ses/adapter'
require 'griddler/amazon_ses/middleware'
require 'griddler/amazon_ses/railtie'

module Griddler
  module AmazonSES
  end
end

Griddler.adapter_registry.register(:amazon_ses, Griddler::AmazonSES::Adapter)
