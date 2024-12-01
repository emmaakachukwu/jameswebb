require_relative '../client'

module Webb
  module Platform
    class Base
      attr_reader :url, :client

      def initialize url
        @url = url
        @client = Webb::Client.new self.class::BASE_URL, headers: self.class::HEADERS
      end

    end
  end
end
