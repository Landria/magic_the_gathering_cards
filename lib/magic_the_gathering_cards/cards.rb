# frozen_string_literal: true
require 'magic_the_gathering_cards/fetcher'

module MagicTheGatheringCards
  class Cards

    attr_accessor :cards_set, :attributes

    class << self
      def fetch
        new.fetch
      end
    end

    def fetch
      @cards_set = Fetcher.run
      @attributes = strong_attrs(cards_set.first)
      self
    end

    def reduce(condition = :strong, **attrs)
      set = cards_set

      attrs.each_pair do |attr, value|
        next unless attr_allowed?(attr)

        set.keep_if do |card|
          v = card.send(attr)
          send("#{condition}_condition", v, value)
        end
      end

      set
    end

    def soft_reduce(**attrs)
      reduce(:soft, attrs)
    end

    def strong_condition(v, value)
      v.is_a?(Array) ? (v & normalized(value)).count == value.count : v == value
    end

    def soft_condition(v, value)
      v.is_a?(Array) ? !(v & normalized(value)).empty? : v =~ regex(value)
    end

    def group_by(*attrs)
      cards_set.sort_by { |card| attrs.map { |attr| card.send(attr) } }
    end

    private

    def normalized(values)
      values.map { |v| v.to_s.capitalize }
    end

    def regex(value)
      v = value.gsub('{', '\{').gsub('}', '\}')
      Regexp.new(v)
    end

    def strong_attrs(card)
      card.to_h.keys
    end

    def attr_allowed?(attr)
      attributes.include?(attr.to_sym)
    end
  end
end
