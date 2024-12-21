require 'uri/http'
require_relative 'webb/option'
require_relative 'webb/platform'
require_relative 'webb/display'

module Webb
  class << self
    def run
      options = Option.parse ARGV
      search_text = ARGV.first

      uri = URI.parse options[:url]
      host_platform = platform uri.host
      source_control_object = host_platform.new uri.path, ref: options[:ref]
      source_control_object.search search_text, &method(:show_results)
    end

    private

    def platform host
      case host
      when /github/
        Platform::Github
      end
    end

    def show_results file_path, results
      return if results.empty?

      Display.log "results in #{file_path}"
      results.each do |result|
        Display.log "#{result.line}. #{result.content}"
      end
      Display.log "\n"
    end
  end
end
