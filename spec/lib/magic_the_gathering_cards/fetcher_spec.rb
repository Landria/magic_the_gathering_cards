require_relative '../../spec_helper'

RSpec.describe MagicTheGatheringCards::Fetcher do
  let(:file) { MagicTheGatheringCards::Settings.cards_local_path }

  it { expect(File).not_to exist(file) }
  let(:cards) { { cards: [] }.to_json }

  it 'fetches remote cards if no local file exists' do
    VCR.use_cassette('cards') do
      expect(File).to_not exist(file)
      cards = described_class.run
      expect(cards.count).to eq 100
      expect(cards.first.name).to eq 'Adorable Kitten'
      expect(File).to exist(file)
    end
  end

  it 'fetches local cards if file valid' do
    VCR.use_cassette('cards') do
      described_class.run
      expect(File).to exist(file)
      expect_any_instance_of(described_class).to receive(:local_cards).and_return(cards)
      expect_any_instance_of(described_class).to_not receive(:remote_cards)
      described_class.run
    end
  end

  it 'fetches remote cards if local file invalid' do
    VCR.use_cassette('cards') do
      described_class.run
      expect(File).to exist(file)

      Timecop.freeze(Time.now + MagicTheGatheringCards::Settings::EXPIRE_IN + 5) do
        expect_any_instance_of(described_class).to receive(:remote_cards).and_return(cards)
        described_class.run
      end
    end
  end

  it 'returs local expired data if remote fetch failed' do
    VCR.use_cassette('cards') do
      expect(described_class.run.count).to eq 100
    end

    VCR.use_cassette('cards-404') do
      Timecop.freeze(Time.now + MagicTheGatheringCards::Settings::EXPIRE_IN + 5) do
        cards = described_class.run
        expect(cards.count).to eq 100
        expect(cards.first.name).to eq 'Adorable Kitten'
      end
    end
  end

  context 'raises error' do
    it 'when 404 returned' do
      VCR.use_cassette('cards-404') do
        expect { described_class.run }.to raise_error(MagicTheGatheringCards::Errors::FetcheError)
      end
    end
  end
end
