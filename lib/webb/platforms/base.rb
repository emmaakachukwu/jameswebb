require 'json'
require_relative '../search_result'
require_relative '../errors/http_error'

module Webb
  module Platform
    class Base
      DEFAULT_REF = :main

      DEFAULT_SEARCH_TYPE = :repo

      def initialize url_path, search_text, ref: nil, type: nil, ignore_case: nil
        @url_path = strip_slashes url_path
        @search_text = search_text
        @ref = ref || DEFAULT_REF
        @ignore_case = ignore_case || false
        @type = type || DEFAULT_SEARCH_TYPE
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
