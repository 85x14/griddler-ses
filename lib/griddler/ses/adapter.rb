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
        sns_msg = SnsEndpoint::AWS::SNS::Message.new sns_json
        raise "Invalid SNS message" unless message_valid?(sns_msg)

        case sns_msg.type
        when :SubscriptionConfirmation
          confirm_sns_subscription_request
          # this is not an actual email reply (and griddler has no way to bail at this point), so return empty parameters
          {}
        when :Notification
          Griddler::Ses::PrepareNotificationParams.new(sns_json).call
        else
          raise "Invalid SNS message type"
        end
      end

      private

      def message_valid?(sns_msg)
        sns_msg.authentic? && sns_msg.topic_arn.end_with?(Griddler::Ses.config.topic_suffix)
      end

      def confirm_sns_subscription_request
        confirmation_endpoint = URI.parse(sns_json['SubscribeURL'])
        Net::HTTP.get confirmation_endpoint
      end
    end
  end
end

