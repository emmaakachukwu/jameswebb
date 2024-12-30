module Webb
  class Error < StandardError; end

  class HTTPError < Error; end

  class MissingCredentials < Error; end

  class InvalidArgument < Error; end

  class ConnectionFailed < Error; end

end
