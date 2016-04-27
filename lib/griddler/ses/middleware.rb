module Griddler
  module Ses
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        # a bug on the AWS side doesn't set the content type to application/json type properly,
        # so we have to intercept and do this in order for Griddler's controller to correctly
        # parse the parameters (see https://forums.aws.amazon.com/thread.jspa?messageID=418160)
        if env['REQUEST_PATH'] == griddler_path
          env['CONTENT_TYPE'] = 'application/json; charset=UTF-8'
        end

        @app.call(env)
      end

      private
      def griddler_path
        @griddler_path ||= Rails.application.routes.url_helpers.url_for(controller: 'griddler/emails', action: 'create', only_path: true)
      end
    end
  end
end
