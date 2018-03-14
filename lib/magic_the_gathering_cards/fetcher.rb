# frozen_string_literal: true

require 'httparty'
require 'magic_the_gathering_cards/errors'
require 'settings'
require 'uri'

module MagicTheGatheringCards
  class Fetcher
    include Settings
  end
end
