require 'json'
require_relative '../client'
require_relative '../errors/http_error'

module Webb
  module Platform
    class Base
      attr_reader :path, :client

      def initialize path
        @path = strip_slashes path
        @client = Client.new self.class::BASE_URL, headers: self.class::HEADERS
      end

      private

      def strip_slashes string
        string.gsub(/\A\/|\/\z/, '')
      end

      def request url_path
        response = client.get url_path

        unless response.is_a? Net::HTTPSuccess
          raise HTTPError, "#{path}: #{response.message}"
        end

        JSON.parse response.body, symbolize_names: true
      end
    end
  end
end
