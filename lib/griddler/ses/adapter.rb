require 'mail'

module Griddler
  module Sparkpost
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
        # TODO
      end
    end
  end
end

