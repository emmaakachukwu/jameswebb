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
      DEFAULT_USER = 'JamesWebb'

      def configure_client
        Octokit::Client.new access_token:, user_agent:
      end

      private

      def user_agent
        ENV.fetch 'WEBB_GITHUB_USER', DEFAULT_USER
      end

      def access_token
        token = ENV['WEBB_GITHUB_TOKEN']
        unless token
          warn "setting `WEBB_GITHUB_TOKEN` increases your rate limit and access to private repositories;\n"\
            "see https://docs.github.com/rest/using-the-rest-api/rate-limits-for-the-rest-api\n\n"
        end

        token
      end

      def namespace_search
        namespace_repos.flat_map do |repo|
          @repo_path = repo.full_name
          @ref = repo.default_branch
          repo_search
        end
      end

      def namespace_repos
        client.org_repos(url_path)
      end

      def repo_search
        repository_files.flat_map do |resource|
          file_content(resource.sha).each_line.filter_map.with_index(1) do |content, line|
            content_case, text_case = ignore_case ?
              [content.downcase, search_text.downcase] :
              [content, search_text]
            SearchResult.new(
              line:,
              content:,
              file: relative_path(resource.path)
            ) if content_case.include? text_case
          end
        end
      end

      def repository_files
        tree = client.tree(repo_path, ref, recursive: true)
        tree.tree.select(&:is_file?)
      rescue Octokit::Conflict
        # empty repo?
        []
      end

      def file_content file_sha
        blob = client.blob(repo_path, file_sha)
        Base64.decode64(blob.content)
      end

      def http_exceptions
        [Octokit::Error]
      end

    end
  end
end
