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

      def search
        search_response = search_via_api
        unless search_response.total_count.positive?
          Display.info "Code in #{url_path} has probably not been indexed;"\
                     " starting a manual search"

          return search_off_api
        end

        search_response.items.flat_map do |resource|
          @repo_path = resource.repository.full_name
          search_resource resource
        end
      rescue *http_exceptions => e
        raise HTTPError, e
      rescue Faraday::ConnectionFailed => e
        raise ConnectionFailed, e
      end

      private

      def configure_client
        Octokit::Client.new access_token:, user_agent:, api_endpoint:
      end

      def user_agent
        ENV.fetch 'WEBB_GITHUB_USER', DEFAULT_USER
      end

      def access_token
        token = ENV['WEBB_GITHUB_TOKEN']
        return token if token

        raise MissingCredentials,
          "Please provide a private_token for Github user via the `WEBB_GITHUB_TOKEN`\n"\
          "see https://docs.github.com/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens"
      end

      def api_endpoint
        env_var = 'WEBB_GITHUB_ENDPOINT'
        api_url = ENV[env_var]
        unless api_url.nil? || valid_uri?(api_url)
          raise InvalidArgument, "'#{env_var}' value is not a valid URL"
        end

        api_url
      end

      def namespace_search
        namespace_repos.flat_map do |repository|
          @repo_path = repository.full_name
          @ref = repository.default_branch
          repo_search
        end
      end

      def namespace_repos
        Display.info "Fetching repositories in namespace: #{url_path}"
        client.org_repos(url_path)
      end

      def repo_search
        repo_files.flat_map(&method(:search_resource))
      end

      def repo_files
        Display.info "Fetching files in repository: #{repo_path}/#{ref}"

        tree = client.tree(repo_path, ref, recursive: true)
        tree.tree.select(&:is_file?)
      rescue Octokit::Conflict
        Display.info "#{repo_path}/#{ref} is empty; skipping"
        []
      end

      def file_content file_sha
        blob = client.blob(repo_path, file_sha)
        Base64.decode64(blob.content)
      end

      def search_resource resource
        Display.info "Searching for `#{search_text}` in #{repo_path}/#{ref}:#{resource.path}"

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
        Display.info "Fetching matching files in #{url_path}"
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
