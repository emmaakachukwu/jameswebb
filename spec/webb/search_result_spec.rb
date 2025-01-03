require_relative '../../lib/webb/search_result'

RSpec.describe Webb::SearchResult do
  let(:file) { 'foo/bar.xyz' }
  let(:line) { 1 }
  let(:content) do
    'Lorem ipsum dolor sit amet'
  end

  describe '#initialize' do
    it 'creates an instance of search result' do
      search_result = described_class.new(file:, line:, content:)

      expect(search_result.line).to eq(1)
      expect(search_result.file).to eq('foo/bar.xyz')
      expect(search_result.content).to eq('Lorem ipsum dolor sit amet')
    end

  end

end
