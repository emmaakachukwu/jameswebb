require 'net/http'

module Webb
  class Client
    attr_reader :base_url, :default_headers

    def initialize(base_url, headers: {})
      @base_url = base_url
      @default_headers = headers
    end

    def get(path, headers: {})
      uri = URI.join base_url, path
      req = Net::HTTP::Get.new uri
      req.initialize_http_header default_headers.merge(headers)

      Net::HTTP.start(
        uri.hostname,
        uri.port,
        use_ssl: uri.scheme == 'https'
      ) do |http|
        http.request(req)
      end
    end
  end
end
