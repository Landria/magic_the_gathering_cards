require_relative 'spec_helper'

RSpec.describe MagicTheGatheringCards::Cards do
  it 'fetches card grouped by set' do
    attrs = { group: [:set] }
    expect(described_class.fetch(attrs)).to eq []
  end
end
