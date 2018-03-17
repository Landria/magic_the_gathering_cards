# frozen_string_literal: true

require_relative 'fetcher'

module MagicTheGatheringCards
  class Cards
    attr_accessor :cards_set, :attributes, :errors, :pages

    class << self
      def fetch(pages = nil)
        new(pages).fetch
      end
    end

    def initialize(pages)
      @errors = []
      @cards_set = []
      @attributes = []
      @pages = pages
    end

    def fetch
      begin
        @cards_set = Fetcher.run(pages)
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

      @cards_set = set
      self
    end

    def soft_reduce(**attrs)
      reduce(:soft, attrs)
    end

    def order_by(*attrs)
      cards_set.sort_by { |card| attrs.map { |attr| card.send(attr) } }
    end

    def group_by(*attrs)
      attrs.keep_if { |attr| attr_allowed?(attr) }
      grouped_set = cards_set

      attrs.each do |attr|
        grouped_set = group_iter(attr, grouped_set)
      end

      grouped_set
    end

    def success?
      errors.empty?
    end

    private

    def strong_condition(card_value, value)
      return false if card_value.nil?
      value.is_a?(Array) ? (card_value.sort == normalized(value).sort) : (card_value == value)
    end

    def soft_condition(card_value, value)
      return false if card_value.nil?
      value.is_a?(Array) ? !(card_value & normalized(value)).empty? : card_value.to_s =~ regex(value)
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
      !attr.nil? && attributes.include?(attr.to_sym)
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

    def group_iter(attr, set)
      grouped_set = {}

      if set.is_a?(Array)
        grouped_set = grouper(attr, set)
      else
        set.each do |k, v|
          grouped_set[k] = group_iter(attr, v)
        end
      end

      grouped_set
    end

    def grouper(attr, set)
      grouped_set = {}

      set.each do |card|
        key = card.send(attr).to_s
        grouped_set[key] ||= []
        grouped_set[key] << card
      end

      grouped_set
    end
  end
end
