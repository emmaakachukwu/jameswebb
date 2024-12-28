require_relative '../../../lib/webb/platform'

RSpec.describe Webb::Platform::Github do
  let(:url_path) { 'emmaakachukwu/jameswebb' }
  let(:search_text) { 'James Webb' }
  let(:ref) { 'main' }
  let(:type) { :repo }
  let(:ignore_case) { false }

  describe '#initialize' do
    context 'creating a github client' do
      it 'uses an Octokit client' do
        github = described_class.new(url_path, search_text)
        expect(github.client).to be_a(Octokit::Client)
      end

    end

  end

  describe '#search' do
    context 'searching through a repo' do
      it 'returns an array of search results when results are found' do
        github = described_class.new(url_path, search_text)
        results = github.search

        expect(results).to be_a(Array)
        expect(results).to_not be_empty
        expect(results.first).to be_a(Webb::SearchResult)
      end

      it 'returns an empty array when results are not found' do
        search_text = '__ non-existing text __'
        github = described_class.new(url_path, search_text)
        results = github.search

        expect(results).to be_a(Array)
        expect(results).to be_empty
      end

      it 'raises a Webb::HTTPError on a request error' do
        url_path = '__non-existing/repo__'
        github = described_class.new(url_path, search_text)

        expect { github.search }.to raise_error(Webb::HTTPError)
      end

    end

    context 'searching through a namespace' do
      let(:url_path) { 'startng' }
      let(:search_text) { 'test' }
      let(:type) { :namespace }

      it 'returns an array of search results when results are found' do
        github = described_class.new(url_path, search_text, type:)
        results = github.search

        expect(results).to be_a(Array)
        expect(results).to_not be_empty
        expect(results.first).to be_a(Webb::SearchResult)
      end

      it 'returns an empty array when results are not found' do
        search_text = '__ non-existing text __'
        github = described_class.new(url_path, search_text, type:)
        results = github.search

        expect(results).to be_a(Array)
        expect(results).to be_empty
      end
    end
  end
end