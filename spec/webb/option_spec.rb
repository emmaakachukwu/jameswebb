require_relative '../../lib/webb/option'

RSpec.describe Webb::Option do
  let(:short_args) do
    [
      '-u', 'https://example.com/foo/bar',
      '-iv',
      '-t', 'repo',
      '--ref', 'main',
      '--p', 'github',
      'search text'
    ]
  end

  let(:long_args) do
    [
      '--url', 'https://example.com/foo/bar',
      '--ignore-case',
      '--verbose',
      '--type', 'namespace',
      '--ref', 'dev',
      '--platform', 'github',
      'search text'
    ]
  end

  describe '.parse' do
    context 'parsing options' do
      it 'parses short form arguments correctly' do
        options = described_class.parse(short_args)

        expect(options.url.to_s).to eq('https://example.com/foo/bar')
        expect(options.ignore_case).to eq(true)
        expect(options.type).to eq(:repo)
        expect(options.ref).to eq('main')
        expect(options.verbose).to be true
        expect(options.platform).to eq('github')
      end

      it 'parses long form arguments correctly' do
        options = described_class.parse(long_args)

        expect(options.url).to be_a(URI::HTTP)
        expect(options.url.to_s).to eq('https://example.com/foo/bar')
        expect(options.ignore_case).to eq(true)
        expect(options.type).to eq(:namespace)
        expect(options.ref).to eq('dev')
        expect(options.verbose).to be true
      end

      it 'returns nil for an undefined option' do
        options = described_class.parse(short_args)
        expect(options.undefined_option).to be nil
      end

      it 'leaves the search text as the only value in the argument reference' do
        args = short_args
        described_class.parse(short_args)

        expect(args.count).to eq(1)
        expect(args.first).to eq('search text')
      end

      it 'parses the URL string correctly' do
        options = described_class.parse(short_args)
        url = options.url

        expect(url).to be_a(URI::HTTP)
        expect(url.scheme).to eq('https')
        expect(url.host).to eq('example.com')
        expect(url.path).to eq('/foo/bar')
      end

      it 'returns nil value for undefined attribute call' do
        options = described_class.parse(short_args)

        expect(options.undefined_attr).to be_nil
      end

      it 'raises OptionParser::InvalidArgument on an invalid argument' do
        expect { described_class.parse(['-u', 'example.com']) }
          .to raise_error(OptionParser::InvalidArgument)
        expect { described_class.parse(['-t', 'invalid_type']) }
          .to raise_error(OptionParser::InvalidArgument)
      end

      it 'raises OptionParser::InvalidOption on an invalid option' do
        expect { described_class.parse(['--invalid_option']) }
          .to raise_error(OptionParser::InvalidOption)
      end

      it 'raises OptionParser::MissingArgument on a missing required option' do
        expect { described_class.parse([]) }
          .to raise_error(OptionParser::MissingArgument)
      end
    end
  end
end
