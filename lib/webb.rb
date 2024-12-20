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
      results = source_control_object.search search_text
      show_results results
    end

    private

    def platform host
      case host
      when /github/
        Platform::Github
      end
    end

    def show_results results
      processed_files = []
      results.each do |result|
        unless processed_files.include? result.file
          Display.log "\n" unless processed_files.empty?
          Display.log "results in #{result.file}"
          processed_files << result.file
        end

        Display.log "#{result.line}. #{result.content}"
      end
    end
  end
end
