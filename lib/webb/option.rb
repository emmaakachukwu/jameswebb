require 'optparse'
require 'optparse/uri'

module Webb
  class Option
    VALID_TYPES = %i[repo namespace].freeze

    REQUIRED_OPTIONS = %i[url].freeze

    class << self
      def parse(args)
        options = {}
        parser(options).parse! args
        validate_required options
        new options
      end

      private

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def parser(options_hash)
        OptionParser.new do |opts|
          opts.banner = 'Usage: webb [args] <search text>'

          opts.on('-u URL', '--url URL', URI, 'link to the source control group') do |url|
            raise OptionParser::InvalidArgument unless url.is_a? URI::HTTP

            options_hash[:url] = url
          end

          opts.on('-t SEARCH_TYPE', '--type SEARCH_TYPE', VALID_TYPES,
                  "type of search; select from #{VALID_TYPES.join(', ')}; defaults to repo") do |type|
            options_hash[:type] = type
          end

          opts.on('--ref REF', String, 'ref object to search in; required if URL is a repository') do |ref|
            options_hash[:ref] = ref
          end

          opts.on('-i', '--ignore-case', TrueClass,
                  'perform case insensitive search; search is case sensitive by default') do |ignore_case|
            options_hash[:ignore_case] = ignore_case
          end

          opts.on('-v', '--verbose', TrueClass,
                  'turn on verbose mode; disabled by default') do |verbose|
            options_hash[:verbose] = verbose
          end

          opts.on('-p PLATFORM', '--platform PLATFORM', String,
                  'select platform to use; default is auto inferred from URL value') do |platform|
            options_hash[:platform] = platform
          end
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def validate_required(options)
        missing = REQUIRED_OPTIONS - options.keys
        raise OptionParser::MissingArgument, missing unless missing.empty?
      end
    end

    def initialize(options)
      options.each do |k, v|
        instance_variable_set "@#{k}", v
        self.class.attr_reader k
      end
    end

    # rubocop:disable Style/MissingRespondToMissing
    def method_missing _method_name, *_args
      nil
    end
    # rubocop:enable Style/MissingRespondToMissing
  end
end
