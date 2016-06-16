module Griddler
  module Ses
    class Config
      # Contains a prefix of the topic which system will expect.
      # This is some kind of very lightweight security.
      # You can change it as you want.
      attr_accessor :topic_suffix

      attr_accessor :aws_region
      attr_accessor :aws_access_key_id
      attr_accessor :aws_secret_access_key

      def initialize
        @topic_suffix = 'griddler'
      end
    end
  end
end
