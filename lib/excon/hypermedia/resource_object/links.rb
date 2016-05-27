# frozen_string_literal: true

module Excon
  module HyperMedia
    class ResourceObject
      # Links
      #
      # Represents a collection of links part of a resource.
      #
      class Links
        include Collection

        private

        def property(value)
          value.respond_to?(:to_ary) ? value.map { |v| LinkObject.new(v) } : LinkObject.new(value)
        end
      end
    end
  end
end
