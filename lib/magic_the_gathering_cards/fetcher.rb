# frozen_string_literal: true

require 'httparty'
require_relative 'errors'
require_relative 'settings'

module MagicTheGatheringCards
  class Fetcher
    include ::HTTParty
    include Errors

    class << self
      def run(pages = nil)
        new(pages).run
      end
    end

    def initialize(pages)
      @pages = pages.to_i.zero? ? Settings.pages_count : pages
    end

    def run
      cards.map { |card| OpenStruct.new(card) }
    rescue TypeError, JSON::ParserError, NoMethodError, Errno::ENOENT
      raise Errors::FetcheError, 'Remote cards fetching error ocurred'
    end

    private

    def cards
      local_cards || remote_cards
    end

    def local_cards(invalidate = true)
      return if !Dir.exist?(Settings.cards_local_dir) || Dir.empty?(Settings.cards_local_dir)
      return if invalidate && file_expired?(Settings.cards_local_path(1))

      files = Dir.entries(Settings.cards_local_dir).select { |f| f =~ /.json\Z/ }
      return if files.count < @pages

      local_cards = []

      (1..files.count).to_a.each do |page|
        local_cards += JSON.parse(File.read(Settings.cards_local_path(page)))['cards']
      end

      local_cards
    end

    def remote_cards
      FileUtils.mkdir_p(Settings.cards_local_dir) unless File.directory?(Settings.cards_local_dir)
      head = self.class.head(Settings.endpoint)
      threads = []

      (1..@pages).to_a.each_slice(Settings.threads_count) do |pages|
        threads << Thread.new(pages) do |pp|
          pp.each do |p|
            next unless file_expired?(Settings.cards_local_path(p))
            remote = self.class.get(Settings.endpoint + "?page=#{p}")
            save_local_cards(remote, p) if remote.success? && (JSON.parse(remote.body)['cards']).count.positive?
          end
        end

        threads.each(&:join)
      end if head.success?

      local_cards(head.success?)
    end

    def save_local_cards(cards, page)
      File.open(Settings.cards_local_path(page), 'w+') do |f|
        f.truncate(0)
        f.write(cards)
      end
    end

    def file_expired?(file)
      return true unless File.exist?(file)
      (File.mtime(file) + Settings.local_cards_expire_in) < Time.now
    end
  end
end
