# frozen_string_literal: true

module MagicTheGatheringCards
  module Settings

    ENDPOINT = 'https://api.magicthegathering.io/v1/cards'.freeze
    EXPIRE_IN = 180
    CARDS_LOCAL_PATH = 'tmp/cards.txt'.freeze
    CARDS_LOCAL_DIR = 'tmp'.freeze
    DEFAULT_THREADS = 4

    class << self
      def endpoint
        ENDPOINT
      end

      def local_cards_expire_in
        EXPIRE_IN
      end

      def cards_local_path
        CARDS_LOCAL_PATH
      end

      def cards_local_dir
        CARDS_LOCAL_DIR
      end

      def threads_count
        DEFAULT_THREADS
      end
    end
  end
end
