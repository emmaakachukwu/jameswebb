module Webb
  module Platform
    class Github < Base
      BASE_URL = 'https://api.github.com/'

      API_VERSION = '2022-11-28'

      USER = ENV['GITHUB_USER']

      HEADERS = {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': API_VERSION,
        'User-Agent': USER
      }

      def search text
        repository_files.filter_map do |resource|
          file_content(resource.sha).each_line.filter_map.with_index(1) do |content, line|
            { file: resource.path, line:, content: } if content.downcase.include? text
          end
        end
      end

      private

      def repository_files
        response = request "repos/#{url_path}/git/trees/#{ref}?recursive=true"
        response[:tree].map do |file|
          Resource.new(**file.slice(:path, :type, :sha, :size))
        end.select { |resource| resource.is_file? }
      end

      def file_content file_sha
        request(
          "repos/#{url_path}/git/blobs/#{file_sha}",
          headers: { 'Accept': 'application/vnd.github.raw+json' }
        )
      end

    end
  end
end
