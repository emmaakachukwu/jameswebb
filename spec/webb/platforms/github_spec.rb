require_relative '../../spec_helper'
require_relative '../../../lib/webb/platform'

RSpec.describe Webb::Platform::Github do
  let(:url_path) { 'emmaakachukwu/jameswebb' }
  let(:search_text) { 'James Webb' }
  let(:ref) { 'main' }
  let(:type) { :repo }
  let(:ignore_case) { false }
  let(:api_env_var) { 'WEBB_GITHUB_ENDPOINT' }

  describe '#initialize' do
    context 'creating a github client' do
      it 'uses an Octokit client' do
        github = described_class.new(url_path, search_text)
        expect(github.client).to be_a(Octokit::Client)
      end

      it 'uses the right endpoint when endpoint is set' do
        endpoint = 'https://api.example.com/'
        ENV[api_env_var] = endpoint
        github = described_class.new(url_path, search_text)
        ENV.delete api_env_var

        expect(github.client.api_endpoint).to eq(endpoint)
      end

      it 'uses the right endpoint when endpoint is set to nil' do
        ENV[api_env_var] = nil
        github = described_class.new(url_path, search_text)
        expect(github.client.api_endpoint).to eq('https://api.github.com/')
      end

      it 'uses the right endpoint when endpoint is not set' do
        github = described_class.new(url_path, search_text)
        expect(github.client.api_endpoint).to eq('https://api.github.com/')
      end

      it 'raises a Webb::InvalidArgument exception when endpoint URL is invalid' do
        ENV[api_env_var] = 'endpoint'
        expect { described_class.new(url_path, search_text) }.to raise_error(
          Webb::InvalidArgument, "'WEBB_GITHUB_ENDPOINT' value is not a valid URL"
        )
        ENV.delete api_env_var
      end

      it 'raises a Webb::MissingCredentials exception when no token is set' do
        token_env_var = 'WEBB_GITHUB_TOKEN'
        token = ENV.fetch(token_env_var, nil)
        ENV.delete token_env_var
        expect { described_class.new(url_path, search_text) }.to raise_error(
          Webb::MissingCredentials,
          "Please provide a private_token for Github user via the `WEBB_GITHUB_TOKEN`\n" \
          'see https://docs.github.com/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens'
        )
        ENV[token_env_var] = token
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
