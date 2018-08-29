$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'griddler'
require 'griddler/testing'
require 'griddler/ses'
require 'rails/version'
require 'action_dispatch'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.order = 'random'
  config.include Griddler::Testing
end
