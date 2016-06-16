require 'aws-sdk'

module Griddler
  module Ses
    module MessageContent
      class S3Fetcher
        attr_reader :action

        def initialize(action)
          @action = action
        end

        def call
          s3_client = init_s3_client
          s3_client
            .bucket(bucket_name)
            .object(object_key)
            .get.body.read
        end

        private

        def init_s3_client
          Aws::S3::Resource.new(
            region: Griddler::Ses.config.aws_region,
            access_key_id: Griddler::Ses.config.aws_access_key_id,
            secret_access_key: Griddler::Ses.config.aws_secret_access_key
          )
        end

        def bucket_name
          action['bucketName']
        end

        def object_key
          action['objectKey']
        end
      end
    end
  end
end
