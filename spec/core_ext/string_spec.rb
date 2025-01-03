require_relative '../../lib/core_ext/string'

RSpec.describe String do
  describe '#highlight' do
    let(:substring) { 'lorem ipsum' }
    let(:text) { 'Lorem Ipsum dolor sit amet. lorem ipsum dolor sit amet' }

    context 'case sensitive search' do
      let(:ignore_case) { false }

      it 'higlights exact matching texts' do
        expect(text.highlight(substring, 33, ignore_case:).inspect).to eq(
          '"Lorem Ipsum dolor sit amet. \e[33mlorem ipsum\e[0m dolor sit amet"'
        )
      end
    end

    context 'case insensitive search' do
      let(:ignore_case) { true }

      it 'higlights matching texts regardless of case' do
        expect(text.highlight(substring, 34, ignore_case:).inspect).to eq(
          '"\e[34mLorem Ipsum\e[0m dolor sit amet. \e[34mlorem ipsum\e[0m dolor sit amet"'
        )
      end
    end
  end
end
