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

  class UnknownPlatform < Error
    PLATFORMS = %i[github gitlab]

    def initialize platform
      super "Unknown platform: #{platform}; valid platforms are: #{PLATFORMS.join(', ')}"\
            "\nThe platform is automatically inferred from the URL"\
            "\nIf you are using a self hosted server,"\
            " you can set the platform using the '--platform' option"\
            " or the 'WEBB_PLATFORM' environment variable"
    end
  end

end
