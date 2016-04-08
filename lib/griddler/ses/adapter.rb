require 'mail'
require 'sns_endpoint'

module Griddler
  module Ses
    class Adapter
      attr_reader :params

      def initialize(params)
        @params = params
      end

      def self.normalize_params(params)
        adapter = new(params)
        adapter.normalize_params
      end

      def normalize_params
        # use sns_endpoint to parse and validate the sns msg
        sns = SnsEndpoint::AWS::SNS::Message.new params
        raise "Invalid SNS message" unless sns.authentic? && sns.topic_arn.end_with?('griddler')

        case sns.type
          when :SubscriptionConfirmation
            confirm_sns_subscription_request
            bail_out_of_reply_handling!
          when :Notification
            ensure_valid_notification_type!
            params.merge(
              to: recipients,
              from: sender,
              cc: cc,
              subject: subject,
              text: message.text_part,
              html: message.html_part,
              headers: raw_headers,
              attachments: attachment_files
            )
          else
            raise "Invalid SNS message type"
          end
        end
      end

      private
      def sns_json
        @sns_json ||= params['_json'][0]
      end

      def notification_type
        sns_json['notificationType']
      end

      def recipients
        sns_json['receipt']['recipients']
      end

      def sender
        sns_json['mail']['commonHeaders']['from'].first
      end

      def cc
        sns_json['mail']['commonHeaders']['cc']
      end

      def subject
        sns_json['mail']['commonHeaders']['subject']
      end

      def message
        @message ||= Mail.read_from_string(sns_json['content'])
      end

      def header_array
        sns_json['mail']['headers']
      end

      def raw_headers
        # SNS gives us an array of hashes with name value, which we need to convert back to raw headers;
        # based on griddler-sparkpost (https://github.com/PrestoDoctor/griddler-sparkpost, MIT license)
        header_array.inject([]) { |raw_headers, sns_hash|
          raw_headers.push("#{sns_hash['name']}: #{sns_hash['value']}")
        }.join("\r\n")
      end

      def attachment_files
        # also based on griddler-sparkpost (https://github.com/PrestoDoctor/griddler-sparkpost, MIT license)
        message.attachments.map do |attachment|
          ActionDispatch::Http::UploadedFile.new({
            type: attachment.mime_type,
            filename: attachment.filename,
            tempfile: tempfile_for_attachment(attachment)
          })
        end
      end

      def tempfile_for_attachment(attachment)
        filename = attachment.filename.gsub(/\/|\\/, '_')
        tempfile = Tempfile.new(filename, Dir::tmpdir, encoding: 'ascii-8bit')
        content = attachment.body.decoded
        tempfile.write(content)
        tempfile.rewind
        tempfile
      end

      def ensure_valid_notification_type!
        raise "Invalid SNS notification type (\"#{notification_type}\", expecting Received" unless notification_type == 'Received'
      end

      def bail_out_of_reply_handling!
        # no way to tell Griddler not to parse the webhook as a reply, so raise an exception to halt further processing
        raise "Request is a subscription confirmation -- this is expected if you're configuring the subscription for AWS for the first time"
      end

      def confirm_sns_subscription_request
        HTTParty.get params['SubscribeURL']
      end
    end
  end
end

