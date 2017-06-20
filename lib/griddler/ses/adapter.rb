require 'mail'
require 'sns_endpoint'
require 'net/http'

module Griddler
  module Ses
    class Adapter
      attr_reader :sns_json

      def initialize(params)
        @sns_json = params
      end

      def self.normalize_params(params)
        adapter = new(params)
        adapter.normalize_params
      end

      def normalize_params
        # use sns_endpoint to parse and validate the sns message
        sns_msg = SnsEndpoint::AWS::SNS::Message.new sns_json
        raise "Invalid SNS message" unless sns_msg.authentic?

        case sns_msg.type
        when :SubscriptionConfirmation
          confirm_sns_subscription_request
          # this is not an actual email reply (and griddler has no way to bail at this point), so return empty parameters
          {}
        when :Notification
          ensure_valid_notification_type!
          sns_json.merge(
            to: recipients,
            from: sender,
            cc: cc,
            bcc: bcc,
            subject: subject,
            text: text_part,
            html: html_part,
            headers: raw_headers,
            attachments: attachment_files
          )
        else
          raise "Invalid SNS message type"
        end
      end

      private
      def email_json
        @email_json ||= JSON.parse(sns_json['Message'])
      end

      def notification_type
        email_json['notificationType']
      end

      def recipients
        email_json['mail']['commonHeaders']['to']
      end

      def sender
        email_json['mail']['commonHeaders']['from'].first
      end

      def cc
        email_json['mail']['commonHeaders']['cc'] || []
      end

      def bcc
        email_json['mail']['commonHeaders']['bcc'] || []
      end

      def subject
        email_json['mail']['commonHeaders']['subject']
      end

      def header_array
        email_json['mail']['headers']
      end

      def message
        @message ||= Mail.read_from_string(Base64.decode64(email_json['content']))
      end

      def multipart?
        message.parts.count > 0
      end

      def text_part
        multipart? ? message.text_part.body.to_s : message.body.to_s
      end

      def html_part
        multipart? ? message.html_part.body.to_s : nil
      end

      def raw_headers
        # SNS gives us an array of hashes with name value, which we need to convert back to raw headers;
        # based on griddler-sparkpost (https://github.com/PrestoDoctor/griddler-sparkpost, MIT license)
        header_array.inject([]) { |raw_headers, sns_hash|
          raw_headers.push("#{sns_hash['name']}: #{sns_hash['value']}")
        }.join("\r\n")
      end

      def attachment_files
        # also based on griddler-sparkpost (https://github.com/PrestoDoctor/griddler-sparkpost, MIT license);
        # AWS doesn't presently support sending the attachments from the message through SNS, but ready if they do!
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

      def confirm_sns_subscription_request
        confirmation_endpoint = URI.parse(sns_json['SubscribeURL'])
        Net::HTTP.get confirmation_endpoint
      end
    end
  end
end

