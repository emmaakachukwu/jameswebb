require_relative '../../../lib/webb/platform'

RSpec.describe Webb::Platform::Github do
  let(:url_path) { '/foo/bar/' }
  let(:search_text) { 'search text' }
  let(:ref) { 'dev' }
  let(:type) { :namespace }
  let(:ignore_case) { true }

  describe '#initialize' do
    context 'creating a client' do
      it 'strips off trailing slashes in the url path' do
        client = described_class.new(url_path, search_text)
        expect(client.url_path).to eq('foo/bar')
      end

      it 'initializes with the right attributes' do
        client = described_class.new(
          url_path,
          search_text,
          ref:,
          type:,
          ignore_case:
        )
        expect(client.search_text).to eq('search text')
        expect(client.repo_path).to eq('foo/bar')
        expect(client.ref).to eq('dev')
        expect(client.type).to eq(:namespace)
        expect(client.ignore_case).to be true
      end

    end

  end

end
