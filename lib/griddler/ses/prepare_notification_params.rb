module Griddler
  module Ses
    class PrepareNotificationParams
      attr_reader :sns_json

      def initialize(sns_json)
        @sns_json = sns_json
      end

      def call
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
      end

      private

      def ensure_valid_notification_type!
        return if notification_type == 'Received'
        raise "Invalid SNS notification type (\"#{notification_type}\", expecting Received"
      end

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

      def raw_headers
        # SNS gives us an array of hashes with name value, which we need to convert back to raw headers;
        # based on griddler-sparkpost (https://github.com/PrestoDoctor/griddler-sparkpost, MIT license)
        header_array.inject([]) { |raw_headers, sns_hash|
          raw_headers.push("#{sns_hash['name']}: #{sns_hash['value']}")
        }.join("\r\n")
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

      def attachment_files
        Griddler::Ses::AttachmentsWrapper.new(message.attachments).call
      end
    end
  end
end
