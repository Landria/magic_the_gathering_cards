# frozen_string_literal: true

require 'httparty'
require 'magic_the_gathering_cards/errors'
require 'magic_the_gathering_cards/settings'

module MagicTheGatheringCards
  class Fetcher
    include ::HTTParty
    include Errors

    class << self
      def run
        new.run
      end
    end

    def run
      JSON.parse(cards)['cards'].map { |card| OpenStruct.new(card) }
    rescue TypeError, JSON::ParserError, NoMethodError, Errno::ENOENT
      raise Errors::FetcheError, 'Remote cards fetching error ocurred'
    end

    private

    def cards
      local_cards || remote_cards
    end

    def local_cards(invalidate = true)
      return unless File.exist?(Settings.cards_local_path)
      return if invalidate && (File.mtime(Settings.cards_local_path) + Settings.local_cards_expire_in) < Time.now
      File.read(Settings.cards_local_path)
    end

    def remote_cards
      remote = self.class.get(Settings.endpoint)
      unless File.directory?(Settings.cards_local_dir)
        FileUtils.mkdir_p(Settings.cards_local_dir)
      end

      File.open(Settings.cards_local_path, 'a+') do |f|
        f.truncate(0)
        f.write(remote)
      end if remote.success?

      local_cards(remote.success?)
    end
  end
end
