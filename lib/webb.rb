require_relative 'webb/option'
require_relative 'webb/platform'
require_relative 'webb/display'
require_relative 'webb/error'
require_relative 'core_ext/string'

module Webb
  class << self
    def run
      options = Option.parse ARGV
      configure_logging options
      search_text = ARGV.first
      host_platform = resolve_host_platform options
      source_control_object = build_source_control_object host_platform, options, search_text
      results = source_control_object.search
      display_results results, search_text, options.ignore_case
    rescue StandardError, Interrupt => e
      handle_error e
    end

    private

    def resolve_host_platform(options)
      platform(options.platform || platform_from_env || options.url.host)
    end

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

    def configure_logging(options)
      Display.logger.level = log_level options
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

    def build_source_control_object(host_platform, options, search_text)
      host_platform.new(
        options.url.path,
        search_text,
        ref: options.ref,
        type: options.type,
        ignore_case: options.ignore_case
      )
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
