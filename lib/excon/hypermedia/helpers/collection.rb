# frozen_string_literal: true

require 'json'

module Excon
  module HyperMedia
    # Collection
    #
    # Given a `Hash`, provides dot-notation properties and other helper methods.
    #
    module Collection
      include Enumerable

      def initialize(collection = {})
        @collection ||= collection
        to_properties
      end

      def each(&block)
        collection.each(&block)
      end

      def keys
        @collection.keys
      end

      def key?(key)
        collection.key?(key.to_s)
      end

      def [](key)
        to_property(key)
      end

      private

      def to_properties
        collection.each do |key, value|
          key = key.downcase
          next unless /[@$"]/ !~ key.to_sym.inspect

          singleton_class.class_eval { attr_reader key }
          instance_variable_set("@#{key}", property(value))
        end
      end

      def property(value)
        value.respond_to?(:keys) ? self.class.new(value) : value
      end

      def to_property(key)
        key?(key) ? property(collection[key]) : nil
      end

      def to_property!(key)
        key?(key) ? to_property(key) : method_missing(key)
      end

      attr_reader :collection
    end
  end
end
