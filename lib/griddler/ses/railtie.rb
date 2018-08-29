require 'rails/version'

module Griddler
  module Ses
    class Railtie < Rails::Railtie
      if Rails::VERSION::MAJOR < 5
        middleware = ActionDispatch::ParamsParser
      else
        middleware = Rack::Head
      end

      initializer "griddler_ses.configure_rails_initialization" do |app|
        Rails.application.middleware.insert_before middleware, Griddler::Ses::Middleware
      end
    end
  end
end
