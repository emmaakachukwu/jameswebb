require_relative '../../../lib/webb/platform'

RSpec.describe Webb::Platform::Gitlab do
  let(:url_path) { 'Jesen92/emmanuel-log-parser' }
  let(:search_text) { 'log parser' }
  let(:ref) { 'main' }
  let(:type) { :repo }
  let(:ignore_case) { false }

  describe '#initialize' do
    context 'creating a gitlab client' do
      it 'uses a Gitlab client' do
        gitlab = described_class.new(url_path, search_text)
        expect(gitlab.client).to be_a(::Gitlab::Client)
      end

    end

  end

  describe '#search' do
    context 'searching through a repo' do
      it 'returns an array of search results when results are found' do
        gitlab = described_class.new(url_path, search_text)
        results = gitlab.search

        expect(results).to be_a(Array)
        expect(results).to_not be_empty
        expect(results.first).to be_a(Webb::SearchResult)
      end

      it 'returns an empty array when results are not found' do
        search_text = '__ non-existing text __'
        gitlab = described_class.new(url_path, search_text)
        results = gitlab.search

        expect(results).to be_a(Array)
        expect(results).to be_empty
      end

      it 'raises a Webb::HTTPError on a request error' do
        url_path = '__non-existing/repo__'
        gitlab = described_class.new(url_path, search_text)

        expect { gitlab.search }.to raise_error(Webb::HTTPError)
      end

    end

    context 'searching through a namespace' do
      let(:url_path) { 'oauth-xx' }
      let(:search_text) { 'bundle' }
      let(:type) { :namespace }

      it 'returns an array of search results when results are found' do
        gitlab = described_class.new(url_path, search_text, type:)
        results = gitlab.search

        expect(results).to be_a(Array)
        expect(results).to_not be_empty
        expect(results.first).to be_a(Webb::SearchResult)
      end

      it 'returns an empty array when results are not found' do
        search_text = '__ non-existing text __'
        gitlab = described_class.new(url_path, search_text, type:)
        results = gitlab.search

        expect(results).to be_a(Array)
        expect(results).to be_empty
      end

    end

  end

end
