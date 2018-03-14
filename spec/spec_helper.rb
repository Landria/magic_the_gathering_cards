# frozen_string_literal: true

require 'magic_the_gathering_cards'
require 'pry'
require 'rspec'

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.color = true
end
