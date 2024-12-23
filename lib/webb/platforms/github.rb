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

      def search
        case @type
        when :repo then repo_search
        when :org then org_search
        end
      rescue Octokit::Error => e
        raise HTTPError, e
      end

      def client
        @client ||= Octokit::Client.new(access_token: TOKEN, user_agent: USER)
      end

      private

      def org_search
        organization_repos.flat_map do |repo|
          @url_path = repo.full_name
          @ref = repo.default_branch
          repo_search
        end
      end

      def repo_search
        repository_files.filter_map do |resource|
          file_content(resource.sha).each_line.filter_map.with_index(1) do |content, line|
            content_case, text_case = @ignore_case ?
              [content.downcase, @search_text.downcase] :
              [content, @search_text]
            SearchResult.new(file: resource.path, line:, content: ) if content_case.include? text_case
          end
        end.flatten
      end

      def organization_repos
        @client.org_repos(@url_path)
      end

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
