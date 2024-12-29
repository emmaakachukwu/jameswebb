require_relative '../../../lib/webb/platform'

RSpec.describe Webb::Platform::Gitlab do
  let(:url_path) { 'Jesen92/emmanuel-log-parser' }
  let(:search_text) { 'log parser' }
  let(:ref) { 'main' }
  let(:type) { :repo }
  let(:ignore_case) { false }
  let(:api_env_var) { 'WEBB_GITLAB_ENDPOINT' }

  describe '#initialize' do
    context 'creating a gitlab client' do
      it 'uses a Gitlab client' do
        gitlab = described_class.new(url_path, search_text)
        expect(gitlab.client).to be_a(::Gitlab::Client)
      end

      it "uses the right endpoint when endpoint is set" do
        endpoint = 'https://example.com'
        ENV[api_env_var] = endpoint
        gitlab = described_class.new(url_path, search_text)
        ENV.delete api_env_var

        expect(gitlab.client.endpoint).to eq(endpoint)
      end

      it 'uses the right endpoint when endpoint is not set' do
        github = described_class.new(url_path, search_text)
        expect(github.client.endpoint).to eq('https://gitlab.com/api/v4')
      end

      it 'raises a Webb::InvalidArgument exception when endpoint URL is invalid' do
        ENV[api_env_var] = 'endpoint'
        expect { described_class.new(url_path, search_text) }.to raise_error(
          Webb::InvalidArgument, "'WEBB_GITLAB_ENDPOINT' value is not a valid URL")
        ENV.delete api_env_var
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
      let(:url_path) { 'gitlab-org/creator-pairing/autodevops-examples' }
      let(:search_text) { 'Auto DevOps' }
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
