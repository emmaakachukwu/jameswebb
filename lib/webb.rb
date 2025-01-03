require_relative 'webb/option'
require_relative 'webb/platform'
require_relative 'webb/display'
require_relative 'webb/error'
require_relative 'core_ext/string'

module Webb
  class << self
    def run
      options = Option.parse ARGV
      Display.logger.level = log_level options
      search_text = ARGV.first
      uri = options.url
      host_platform = platform(options.platform || platform_from_env || uri.host)
      source_control_object = host_platform.new(
        uri.path,
        search_text,
        ref: options.ref,
        type: options.type,
        ignore_case: options.ignore_case
      )
      results = source_control_object.search
      display_results results, search_text, options.ignore_case
    rescue StandardError, Interrupt => e
      handle_error e
    end

    private

    def platform(host)
      case host
      when /github/ then Platform::Github
      when /gitlab/ then Platform::Gitlab
      else raise UnknownPlatform, host.split('.').first
      end
    end

    def display_results(results, search_text, ignore_case)
      processed_files = []
      results.each do |result|
        unless processed_files.include? result.file
          Display.log "\n" unless processed_files.empty?
          Display.log "results in #{result.file}"
          processed_files << result.file
        end
        Display.log "#{result.line}. #{result.content.highlight search_text, 33, ignore_case:}"
      end
    end

    def log_level(options)
      if options.verbose
        Logger::INFO
      else
        Logger::WARN
      end
    end

    def platform_from_env
      ENV.fetch('WEBB_PLATFORM', nil)
    end

    def handle_error(error)
      case error
      when Interrupt then abort 'Process interrupted; stopping gracefully'
      when Webb::Error then abort error.message
      when OptionParser::ParseError
        Display.error error.message
        abort `webb --help`
      else raise error
      end
    end
  end
end
