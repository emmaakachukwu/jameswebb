require 'octokit'
require 'base64'

Sawyer::Resource.class_eval do
  def file?
    type == 'blob'
  end

  def file_ref
    sha
  end
end

module Webb
  module Platform
    class Github < Base
      DEFAULT_USER = 'JamesWebb'.freeze

      REQUIRED_SCOPES = %w[repo read:org].freeze

      def search
        search_response = search_via_api
        return handle_unindexed_code if search_response.total_count.zero?

        search_response.items.flat_map { |resource| process_resource(resource) }
      rescue Octokit::Error => e
        handle_error e
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
        token = ENV.fetch('WEBB_GITHUB_TOKEN', nil)
        return token if token

        raise MissingCredentials,
              "Please provide a private_token for Github user via the `WEBB_GITHUB_TOKEN`\n" \
              'see https://docs.github.com/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens'
      end

      def api_endpoint
        env_var = 'WEBB_GITHUB_ENDPOINT'
        api_url = ENV.fetch(env_var, nil)
        raise InvalidArgument, "'#{env_var}' value is not a valid URL" unless api_url.nil? || valid_uri?(api_url)

        api_url
      end

      def namespace_search
        namespace_repos.flat_map do |repository|
          update_repo_context repository
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
        tree.tree.select(&:file?)
      rescue Octokit::Conflict
        Display.info "#{repo_path}/#{ref} is empty; skipping"
        []
      end

      def file_content(file_sha)
        blob = client.blob(repo_path, file_sha)
        Base64.decode64(blob.content)
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

      def handle_unindexed_code
        Display.info "Code in #{url_path} has probably not been indexed; starting a manual search"
        search_off_api
      end

      def process_resource(resource)
        update_repo_context(resource.repository)
        search_resource(resource)
      end

      def update_repo_context(repository)
        @repo_path = repository.full_name
        @ref = repository.default_branch unless repository.default_branch.nil?
      end

      def validate_required_scopes!(error)
        token_scopes = error.response_headers['x-oauth-scopes'].split ', '
        missing_scopes = REQUIRED_SCOPES - token_scopes

        raise MissingScopes, missing_scopes unless missing_scopes.empty?
      end

      def build_query
        query = "#{search_text} "
        query += type == :repo ? 'repo' : 'org'

        "#{query}:#{repo_path}"
      end

      def handle_error(error)
        validate_required_scopes! error if error.is_a? Octokit::NotFound
        raise HTTPError, error
      end
    end
  end
end
