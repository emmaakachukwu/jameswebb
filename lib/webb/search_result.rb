module Webb
  class SearchResult
    attr_reader :file, :line, :content

    def initialize file:, line:, content:
      @file = file
      @line = line
      @content = content
    end
  end
end
