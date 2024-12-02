require 'uri/http'
require_relative 'webb/option'
require_relative 'webb/platform'

module Webb
  class << self
    def run
      options = Option.parse ARGV
      search_text = ARGV.first

      uri = URI.parse options[:url]
      host_platform = platform uri.host
      sc_object = host_platform.new uri.path
      sc_object.search search_text
    end

    private

    def platform host
      case host
      when /github/
        Platform::Github
      end
    end
  end
end
