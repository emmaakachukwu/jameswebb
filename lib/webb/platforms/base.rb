require 'json'
require_relative '../client'
require_relative '../resource'
require_relative '../errors/http_error'

module Webb
  module Platform
    class Base
      attr_reader :url_path, :ref, :client

      def initialize url_path, ref
        @url_path = strip_slashes url_path
        @ref = ref
        @client = Client.new self.class::BASE_URL, headers: self.class::HEADERS
      end

      private

      def strip_slashes string
        string.gsub(/\A\/|\/\z/, '')
      end

      def request path, headers: {}
        response = client.get(path, headers:)

        unless response.is_a? Net::HTTPSuccess
          raise HTTPError, "#{url_path}: #{response.message}"
        end

        JSON.parse response.body, symbolize_names: true
      rescue JSON::ParserError
        response.body
      end
    end
  end
end
