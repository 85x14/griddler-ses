module Griddler
  module Ses
    module MessageContent
      class << self
        def resolve(email_json)
          if action_s3?(email_json)
            MessageContent::S3Fetcher.new(email_json['receipt']['action']).call
          else
            MessageContent::FromParamsFetcher.new(email_json).call
          end
        end

        private

        def action_s3?(email_json)
          email_json['receipt']['action']['type'] == 'S3'
        end
      end
    end
  end
end
