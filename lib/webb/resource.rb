module Webb
  class Resource
    attr_reader :path, :type, :sha, :size

    def initialize(path:, type:, sha:, size: nil)
      @path = path
      @type = type
      @sha = sha
      @size = size
    end

    def file?
      type == 'blob'
    end
  end
end
