# frozen_string_literal: true

require_relative 'fetcher'

module MagicTheGatheringCards
  class Cards
    attr_accessor :cards_set, :attributes, :errors

    class << self
      def fetch
        new.fetch
      end
    end

    def initialize
      @errors = []
      @cards_set = []
      @attributes = []
    end

    def fetch
      begin
        @cards_set = Fetcher.run
        @attributes = strong_attrs(cards_set.first)
      rescue MagicTheGatheringCards::Errors::FetcheError => e
        @errors << e.message
      end

      self
    end

    def reduce(condition = :strong, **attrs)
      set = []
      threads = []

      cards_set.each_slice(Settings.threads_count) do |sub_set|
        threads << Thread.new(sub_set) do |s_set|
          set += check_card(attrs, s_set, condition)
        end

        threads.each(&:join)
      end

      set
    end

    def soft_reduce(**attrs)
      reduce(:soft, attrs)
    end

    def group_by(*attrs)
      cards_set.sort_by { |card| attrs.map { |attr| card.send(attr) } }
    end

    def success?
      errors.empty?
    end

    private

    def strong_condition(v, value)
      v.is_a?(Array) ? (v & normalized(value)).count == value.count : v == value
    end

    def soft_condition(v, value)
      v.is_a?(Array) ? !(v & normalized(value)).empty? : v =~ regex(value)
    end

    def normalized(values)
      values.map { |v| v.to_s.capitalize }
    end

    def regex(value)
      v = value.gsub('{', '\{').gsub('}', '\}')
      Regexp.new(v, Regexp::IGNORECASE)
    end

    def strong_attrs(card)
      card.to_h.keys
    end

    def attr_allowed?(attr)
      attributes.include?(attr.to_sym)
    end

    def check_card(attrs, set, condition)
      attrs.each_pair do |attr, value|
        next unless attr_allowed?(attr)

        set.keep_if do |card|
          v = card.send(attr)
          send("#{condition}_condition", v, value)
        end
      end

      set
    end
  end
end
