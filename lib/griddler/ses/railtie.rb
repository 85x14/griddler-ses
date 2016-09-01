module Griddler
  module Ses
    class Railtie < Rails::Railtie
      initializer "griddler_ses.configure_rails_initialization" do |app|
        if ::Rails::VERSION::MAJOR >= 5
          # Rails 5 no longer instantiates ActionDispatch::ParamsParser
          # https://github.com/rails/rails/commit/a1ced8b52ce60d0634e65aa36cb89f015f9f543d
          Rails.application.middleware.use Middleware
          Rails.application.middleware.use Griddler::Ses::Middleware
        else
          Rails.application.middleware.insert_before ActionDispatch::ParamsParser, Griddler::Ses::Middleware
        end
      end
    end
  end
end
