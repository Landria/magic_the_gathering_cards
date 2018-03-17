# frozen_string_literal: true

module MagicTheGatheringCards
  module Settings
    ENDPOINT = 'https://api.magicthegathering.io/v1/cards'
    EXPIRE_IN = 300
    CARDS_LOCAL_PATH = ->(page) { "tmp/cards_#{page}.json" }
    CARDS_LOCAL_DIR = 'tmp'
    DEFAULT_THREADS = 4
    DEFAULT_PAGES_COUNT = 400

    class << self
      def endpoint
        ENDPOINT
      end

      def local_cards_expire_in
        EXPIRE_IN
      end

      def cards_local_path(page)
        CARDS_LOCAL_PATH.call(page)
      end

      def cards_local_dir
        CARDS_LOCAL_DIR
      end

      def threads_count
        DEFAULT_THREADS
      end

      def pages_count
        DEFAULT_PAGES_COUNT
      end
    end
  end
end
