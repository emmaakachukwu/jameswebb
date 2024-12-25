require 'optparse'
require 'optparse/uri'

module Webb
  class Option
    VALID_TYPES = %i[repo namespace]

    class << self
      def parse args
        options = {}
        parser(options).parse! args
        new options
      end

      private

      def parser options_hash
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
        end
      end
    end

    def initialize options
      options.each do |k, v|
        instance_variable_set "@#{k}", v
        self.class.attr_reader k
      end
    end

    def method_missing method_name, *args
      nil
    end
  end
end
