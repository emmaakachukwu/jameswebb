require 'octokit'
require 'base64'

Sawyer::Resource.class_eval do
  def is_file?
    type == 'blob'
  end
end

module Webb
  module Platform
    class Github < Base
      USER = ENV['GITHUB_USER']

      TOKEN = ENV['GITHUB_TOKEN']

      def search text
        repository_files.filter_map do |resource|
          file_content(resource.sha).each_line.filter_map.with_index(1) do |content, line|
            { file: resource.path, line:, content: } if content.downcase.include? text
          end
        end.flatten.map { |result| SearchResult.new(**result) }
      rescue Octokit::Error => e
        raise HTTPError, e
      end

      def client
        @client ||= Octokit::Client.new(access_token: TOKEN, user_agent: USER)
      end

      private

      def repository_files
        tree = @client.tree(@url_path, @ref, recursive: true)
        tree.tree.select(&:is_file?)
      end

      def file_content file_sha
        blob = @client.blob(@url_path, file_sha)
        Base64.decode64(blob.content)
      end

    end
  end
end
