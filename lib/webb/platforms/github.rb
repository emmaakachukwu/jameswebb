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
        when :repo then
          @repo_path = @url_path
          repo_search
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
          @repo_path = repo.full_name
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
            SearchResult.new(
              line:,
              content:,
              file: relative_path(resource.path)
            ) if content_case.include? text_case
          end
        end.flatten
      end

      def organization_repos
        @client.org_repos(@url_path)
      end

      def repository_files
        tree = @client.tree(@repo_path, @ref, recursive: true)
        tree.tree.select(&:is_file?)
      end

      def file_content file_sha
        blob = @client.blob(@repo_path, file_sha)
        Base64.decode64(blob.content)
      end

      def relative_path file_path
        "#{@repo_path}/#{file_path}".delete_prefix("#{@url_path}/")
      end

    end
  end
end
