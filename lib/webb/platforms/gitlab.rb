require 'gitlab'
require 'base64'

Gitlab::ObjectifiedHash.class_eval do
  def is_file?
    type == 'blob'
  end
end

module Webb
  module Platform
    class Gitlab < Base
      BASE_URL = 'https://gitlab.com/api/v4'

      TOKEN = ENV['GITLAB_TOKEN']

      def search
        case @type
        when :repo then
          @repo_path = @url_path
          repo_search
        end
      rescue ::Gitlab::Error::ResponseError => e
        raise HTTPError, e
      end

      def client
        @client ||= ::Gitlab.client(
          endpoint: BASE_URL,
          private_token: TOKEN
        )
      end

      private

      def repo_search
        repository_files.flat_map do |resource|
          file_content(resource.path).each_line.filter_map.with_index(1) do |content, line|
            content_case, text_case = @ignore_case ?
              [content.downcase, @search_text.downcase] :
              [content, @search_text]
            SearchResult.new(
              line:,
              content:,
              file: relative_path(resource.path)
            ) if content_case.include? text_case
          end
        end
      end

      def repository_files
        tree = @client.tree(@repo_path, ref: @ref, recursive: true)
        tree.select(&:is_file?)
      end

      def file_content file_path
        file = @client.get_file(@repo_path, file_path, @ref)
        Base64.decode64(file.content)
      end

      def relative_path file_path
        "#{@repo_path}/#{file_path}".delete_prefix("#{@url_path}/")
      end
    end
  end
end
