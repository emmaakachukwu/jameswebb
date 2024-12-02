require 'json'
require_relative '../client'
require_relative '../errors/http_error'

module Webb
  module Platform
    class Base
      attr_reader :url_path, :client

      def initialize url_path
        @url_path = strip_slashes url_path
        @client = Client.new self.class::BASE_URL, headers: self.class::HEADERS
      end

      private

      def strip_slashes string
        string.gsub(/\A\/|\/\z/, '')
      end

      def request path
        response = client.get path

        unless response.is_a? Net::HTTPSuccess
          raise HTTPError, "#{url_path}: #{response.message}"
        end

        JSON.parse response.body, symbolize_names: true
      end
    end
  end
end
