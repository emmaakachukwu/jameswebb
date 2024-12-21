require 'uri/http'
require_relative 'webb/option'
require_relative 'webb/platform'
require_relative 'webb/display'
require_relative 'webb/errors/http_error'

module Webb
  class << self
    def run
      options = Option.parse ARGV
      search_text = ARGV.first

      uri = URI.parse options[:url]
      host_platform = platform uri.host
      source_control_object = host_platform.new uri.path, ref: options[:ref], ignore_case: options[:ignore_case]
      source_control_object.search search_text, &method(:show_results)
    rescue StandardError, Interrupt => e
      handle_error e
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

    def handle_error error
      case error
      when Interrupt then abort 'Process interrupted; stopping gracefully'
      when HTTPError then abort error.message
      when OptionParser::ParseError then
        Display.log error.message
        abort `webb --help`
      else raise error
      end
    end
  end
end
