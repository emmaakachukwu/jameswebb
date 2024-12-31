module Webb
  class Error < StandardError; end

  class HTTPError < Error; end

  class MissingCredentials < Error; end

  class InvalidArgument < Error; end

  class ConnectionFailed < Error; end

  class MissingScopes < Error
    def initialize missing = []
      super "The token is missing required scopes#{(": '" + missing.join(', ') + "'") unless missing.empty?}"\
            ' to ensure access to namespaces and private repositories'
    end

  end

end
