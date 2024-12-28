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

      def search
        search_response = search_via_api
        return search_off_api unless search_response.total_count.positive?

        search_response.items.flat_map do |resource|
          @repo_path = resource.repository.full_name
          search_resource resource
        end
      rescue *http_exceptions => e
        raise HTTPError, e
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
        namespace_repos.flat_map do |repository|
          @repo_path = repository.full_name
          @ref = repository.default_branch
          repo_search
        end
      end

      def namespace_repos
        client.org_repos(url_path)
      end

      def repo_search
        repo_files.flat_map(&method(:search_resource))
      end

      def repo_files
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

      def search_resource resource
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

      def search_via_api
        client.search_code build_query
      end

      def search_off_api
        case type
        when :repo then repo_search
        when :namespace then namespace_search
        end
      end

      def build_query
        query = "#{search_text} "
        query += type == :repo ? 'repo' : 'org'

        "#{query}:#{repo_path}"
      end

      def http_exceptions
        [Octokit::Error]
      end

    end
  end
end
