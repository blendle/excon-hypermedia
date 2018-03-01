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
        @collection ||= collection.to_h
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

      # method_missing
      #
      # Collections can be accessed using both the "dot notation" and the hash
      # notation:
      #
      #   collection.hello_world
      #   collection['hello_world']
      #
      # The second notation returns `nil` on missing keys, the first should do
      # as well.
      #
      def method_missing(_) # rubocop:disable Style/MethodMissing
        nil
      end

      # respond_to_missing?
      #
      # Checking if a key exists should be possible using `respond_to?`:
      #
      #   collection.respond_to?(:hello_world)
      #   # => false
      #
      def respond_to_missing?(_, _ = false)
        super
      end

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
