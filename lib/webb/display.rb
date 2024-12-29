require 'logger'

module Webb
  class Display
    class << self
      def log text
        puts text
      end

      def logger
        @logger ||= Logger.new STDOUT
      end

      private

      def method_missing method_name, *args
        return logger.send method_name, *args if logger.respond_to? method_name
        super
      end
    end
  end
end
