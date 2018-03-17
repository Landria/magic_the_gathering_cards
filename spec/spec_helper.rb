# frozen_string_literal: true

require 'magic_the_gathering_cards'
require 'pry'
require 'rspec'
require 'vcr'
require 'timecop'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.color = true

  config.after(:each) do
    FileUtils.rm_rf Dir.glob("#{MagicTheGatheringCards::Settings.cards_local_dir}/*")
  end

  config.before(:each) do
    FileUtils.rm_rf Dir.glob("#{MagicTheGatheringCards::Settings.cards_local_dir}/*")
  end
end
