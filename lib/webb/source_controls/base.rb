module Webb
  module SourceControl
    class Base
      attr_reader :url

      def initialize url
        @url = url
      end

      def search text
        puts text
      end
    end
  end
end
