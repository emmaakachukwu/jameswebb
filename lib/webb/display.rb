require 'logger'

module Webb
  class Display
    class << self
      def log(text)
        puts text
      end

      def logger
        @logger ||= Logger.new $stdout
      end

      private

      def method_missing(method_name, *)
        return logger.send(method_name, *) if logger.respond_to? method_name

        super
      end

      def respond_to_missing?(method_name, *)
        logger.respond_to?(method_name) || super
      end
    end
  end
end
