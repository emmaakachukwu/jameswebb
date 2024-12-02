require 'uri/http'
require_relative 'webb/option'
require_relative 'webb/platform'

module Webb
  class << self
    def run
      options = Option.parse ARGV
      search_text = ARGV.first

      uri = URI.parse options[:url]
      sc = platform uri.host
      sc_object = sc.new uri.path
      sc_object.search search_text
    end

    def source_control_host url
      URI.parse(url).host
    end

    def platform host
      case host
      when /github/
        Platform::Github
      end
    end
  end
end
