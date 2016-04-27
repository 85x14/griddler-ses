require 'griddler'
require 'griddler/ses/version'
require 'griddler/ses/adapter'
require 'griddler/ses/middleware'
require 'griddler/ses/railtie'

module Griddler
  module Ses
  end
end

Griddler.adapter_registry.register(:ses, Griddler::Ses::Adapter)
