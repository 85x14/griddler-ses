module Griddler
  module Ses
    module MessageContent
      class FromParamsFetcher
        attr_reader :email_json

        def initialize(email_json)
          @email_json = email_json
        end

        def call
          Base64.decode64(email_json['content'])
        end
      end
    end
  end
end
