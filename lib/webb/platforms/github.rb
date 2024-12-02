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
        repository_files.each do |file|
          puts file[:name]
        end
      end

      private

      def repository_files
        request "repos/#{path}/contents"
      end

    end
  end
end
