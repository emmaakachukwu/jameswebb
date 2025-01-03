require 'gitlab'
require 'base64'

Gitlab::ObjectifiedHash.class_eval do
  def file?
    type == 'blob'
  end
end

module Webb
  module Platform
    class Gitlab < Base
      DEFAULT_ENDPOINT = 'https://gitlab.com/api/v4'.freeze

      def search
        unique_resources.flat_map { |resource| process_resource(resource) }
      rescue *http_exceptions => e
        raise HTTPError, e
      rescue SocketError => e
        raise ConnectionFailed, e
      end

      private

      def configure_client
        ::Gitlab.client endpoint:, private_token:
      end

      def endpoint
        env_var = 'WEBB_GITLAB_ENDPOINT'
        api_url = ENV.fetch 'WEBB_GITLAB_ENDPOINT', DEFAULT_ENDPOINT
        raise InvalidArgument, "'#{env_var}' value is not a valid URL" unless valid_uri?(api_url)

        api_url
      end

      def private_token
        token = ENV.fetch('WEBB_GITLAB_TOKEN', nil)
        return token if token

        raise MissingCredentials,
              "Please provide a private_token for Gitlab user via the `WEBB_GITLAB_TOKEN`\n" \
              'see https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#create-a-personal-access-token'
      end

      def namespace_search
        namespace_repos.flat_map do |repo|
          @repo_path = repo.path_with_namespace
          @ref = repo.default_branch
          repo_search
        end
      end

      def namespace_repos
        client.group_projects(
          url_path,
          include_subgroups: true,
          simple: true
        )
      end

      def repo_search
        repo_files.flat_map(&method(:search_resource))
      end

      def repo_files
        tree = client.tree(repo_path, ref:, recursive: true)
        tree.select(&:file?)
      end

      def file_content(file_path)
        file = client.get_file(repo_path, file_path, ref)
        Base64.decode64(file.content)
      end

      def search_resource(resource)
        Display.info "Searching for `#{search_text}` in #{repo_path}/#{ref}:#{resource.path}"

        file_content(resource.path).each_line.filter_map.with_index(1) do |content, line|
          next unless text_matches? content

          build_search_result(line, content, resource.path)
        end
      end

      def search_via_api
        Display.info "Fetching matching files in #{url_path}"

        case type
        when :repo
          client.search_in_project(url_path, 'blobs', search_text, ref)
        when :namespace
          client.search_in_group(url_path, 'blobs', search_text)
        end
      end

      def project(id)
        @projects ||= {}
        return @projects[id] if @projects.key?(id)

        @projects[id] = client.project id
      end

      def unique_resources
        search_via_api.uniq { |resource| resource_key(resource) }
      end

      def resource_key(resource)
        "#{resource.project_id}/#{resource.path}/#{resource.ref}"
      end

      def process_resource(resource)
        update_project_context resource
        search_resource resource
      end

      def update_project_context(resource)
        resource_project = project(resource.project_id)
        @repo_path = resource_project.path_with_namespace
        @ref = resource_project.default_branch
      end

      def text_matches?(text)
        text_case = ignore_case ? text.downcase : text
        search_text_case = ignore_case ? search_text.downcase : search_text
        text_case.include?(search_text_case)
      end

      def build_search_result(line, content, file_path)
        SearchResult.new(line:, content:, file: relative_path(file_path))
      end

      def http_exceptions
        [::Gitlab::Error::ResponseError]
      end
    end
  end
end
