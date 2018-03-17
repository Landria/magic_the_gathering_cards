require_relative '../../spec_helper'

RSpec.describe MagicTheGatheringCards::Cards do
  let(:cards) { MagicTheGatheringCards::Fetcher.run }

  it 'fetches card grouped by set' do
    VCR.use_cassette('cards') do
      expect(described_class.fetch.group_by(:set).cards_set).to eq(cards.sort_by { |attrs| attrs.set })
    end
  end

  it 'fetches card grouped by set and rarity' do
    VCR.use_cassette('cards') do
      set = described_class.fetch.group_by(:set, :rarity).cards_set
      expect(set).to eq(cards.sort_by { |attrs| [attrs.set, attrs.rarity] })
      expect(set).to_not eq cards
    end
  end

  it 'fetches card with only red AND blue colors' do
    VCR.use_cassette('cards') do
      set = described_class.fetch.reduce(colors: [:red, :blue]).cards_set
      expect(set.map(&:colors).uniq).to eq []
    end
  end

  it 'fetches card with only white colors ' do
    VCR.use_cassette('cards') do
      set = described_class.fetch.reduce(colors: [:white]).cards_set
      expect(set.map(&:colors).uniq).to eq [['White']]
    end
  end

  it 'fetches card with only types ["Host","Creature"] ' do
    VCR.use_cassette('cards') do
      set = described_class.fetch.reduce(types: [:host, :creature]).cards_set
      expect(set.map(&:types).uniq).to eq [["Host","Creature"]]
    end
  end

  it 'skips reduce on wrong attribute' do
    VCR.use_cassette('cards') do
      set = described_class.fetch.reduce(superTypes: [:host, :creature], colors: [:red]).cards_set
      expect(set.map(&:colors).uniq).to eq [['Red']]
    end
  end

  it 'fetches card with only red OR blue colors' do
    VCR.use_cassette('cards') do
      set = described_class.fetch.soft_reduce(colors: [:red, :blue]).cards_set
      expect(set.map(&:colors).uniq).to eq [['Blue'], ['Red']]
    end
  end

  it 'fetches card with only colors red OR blue and manaCost with "{3}{U}"' do
    VCR.use_cassette('cards') do
      set = described_class.fetch.soft_reduce(colors: [:red, :blue], manaCost: '{3}{U}').cards_set
      expect(set.map(&:colors).uniq).to eq [['Blue']]
      expect(set.map(&:manaCost).uniq).to eq ['{3}{U}', '{3}{U}{U}']
    end
  end

  it 'fetches case insensitive"' do
    VCR.use_cassette('cards') do
      set = described_class.fetch.soft_reduce(type: 'Legendary').cards_set
      set2 = described_class.fetch.soft_reduce(type: 'legendary').cards_set
      expect(set).to eq set2
    end
  end

  it 'fetches card with only manaCost equals "{3}{U}"' do
    VCR.use_cassette('cards') do
      set = described_class.fetch.reduce(manaCost: '{3}{U}').cards_set
      expect(set.map(&:colors).uniq).to eq [['Blue']]
      expect(set.map(&:manaCost).uniq).to eq ['{3}{U}']
    end
  end

  it 'fetches card with 404"' do
    VCR.use_cassette('cards-404') do
      set = described_class.fetch
      expect(set.cards_set).to eq []
      expect(set.success?).to be_falsey
      expect(set.errors).to eq ['Remote cards fetching error ocurred']
    end
  end
end
