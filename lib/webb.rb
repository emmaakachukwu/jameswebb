require 'uri/http'
require_relative 'webb/option'
require_relative 'webb/platform'

module Webb
  class << self
    def run
      options = Webb::Option.parse ARGV
      search_text = ARGV.first

      host = source_control_host options[:url]
      sc = source_control host
      sc_object = sc.new options[:url]
      sc_object.search search_text
    end

    def source_control_host url
      URI.parse(url).host
    end

    def source_control host
      case host
      when /github/
        Webb::Platform::Github
      end
    end
  end
end
