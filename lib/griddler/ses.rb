require 'griddler'
require 'griddler/ses/version'
require 'griddler/ses/adapter'

module Griddler
  module Ses
  end
end

Griddler.adapter_registry.register(:ses, Griddler::Ses::Adapter)
