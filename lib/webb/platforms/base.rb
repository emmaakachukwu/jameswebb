require 'json'
require 'uri'
require_relative '../search_result'
require_relative '../error'

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

      def initialize(url_path, search_text, ref: nil, type: nil, ignore_case: nil)
        @url_path = strip_slashes url_path
        @repo_path = @url_path
        @search_text = search_text
        @ref = ref || DEFAULT_REF
        @ignore_case = ignore_case || DEFAULT_IGNORE_CASE
        @type = type || DEFAULT_SEARCH_TYPE
        @client = configure_client
      end

      private

      def configure_client
        nil
      end

      def strip_slashes(string)
        string.gsub(%r{\A/|/\z}, '')
      end

      def request(path, headers: {})
        response = client.get(path, headers:)

        raise HTTPError, "#{url_path}: #{response.message}" unless response.is_a? Net::HTTPSuccess

        JSON.parse response.body, symbolize_names: true
      rescue JSON::ParserError
        response.body
      end

      def search_resource(resource)
        Display.info "Searching for `#{search_text}` in #{full_repo_path}:#{resource.path}"

        file_content(resource.file_ref).each_line.filter_map.with_index(1) do |content, line|
          next unless text_matches? content

          build_search_result(line, content, resource.path)
        end
      end

      def text_matches?(text)
        text_case = ignore_case ? text.downcase : text
        search_text_case = ignore_case ? search_text.downcase : search_text
        text_case.include?(search_text_case)
      end

      def build_search_result(line, content, file_path)
        SearchResult.new(line:, content:, file: relative_path(file_path))
      end

      def relative_path(file_path)
        "#{repo_path}/#{file_path}".delete_prefix("#{url_path}/")
      end

      def valid_uri?(uri)
        uri.match? URI::DEFAULT_PARSER.make_regexp
      end

      def full_repo_path
        "#{repo_path}/#{ref}"
      end
    end
  end
end
