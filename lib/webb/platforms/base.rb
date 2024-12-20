require 'json'
require_relative '../search_result'
require_relative '../errors/http_error'

module Webb
  module Platform
    class Base
      def initialize url_path, ref: nil
        @url_path = strip_slashes url_path
        @ref = ref || 'main'
        @client = client
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
