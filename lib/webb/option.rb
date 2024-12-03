require 'optparse'

module Webb
  class Option
    class << self
      def parse args
        options = {}
        parser(options).parse! args
        options
      end

      private

      def parser options_hash
        OptionParser.new do |opts|
          opts.banner = 'Usage: webb [args] <search text>'

          opts.on('-u URL', '--url URL', 'link to the source control group') do |url|
            options_hash[:url] = url
          end

          opts.on('--ref REF', 'ref object to search in; required if URL is a repository') do |ref|
            options_hash[:ref] = ref
          end
        end
      end
    end
  end
end
