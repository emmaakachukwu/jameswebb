require 'json'
require_relative '../search_result'
require_relative '../errors/http_error'
require_relative '../errors/missing_credentials'

module Webb
  module Platform
    class Base
      DEFAULT_REF = :main

      DEFAULT_SEARCH_TYPE = :repo

      DEFAULT_IGNORE_CASE = false

      attr_reader :url_path,
                  :repo_path,
                  :search_text,
                  :ref,
                  :ignore_case,
                  :type,
                  :client

      def initialize url_path, search_text, ref: nil, type: nil, ignore_case: nil
        @url_path = strip_slashes url_path
        @repo_path = @url_path
        @search_text = search_text
        @ref = ref || DEFAULT_REF
        @ignore_case = ignore_case || DEFAULT_IGNORE_CASE
        @type = type || DEFAULT_SEARCH_TYPE
        @client = configure_client
      end

      def search
        case type
        when :repo then repo_search
        when :namespace then namespace_search
        end
      rescue *http_exceptions => e
        raise HTTPError, e
      end

      private

      def configure_client
        nil
      end

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

      def relative_path file_path
        "#{repo_path}/#{file_path}".delete_prefix("#{url_path}/")
      end

      def http_exceptions
        []
      end
    end
  end
end
