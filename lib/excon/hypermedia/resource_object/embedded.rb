# frozen_string_literal: true

module Excon
  module HyperMedia
    class ResourceObject
      # Links
      #
      # Represents a collection of links part of a resource.
      #
      class Embedded
        include Collection

        private def property(value)
          if value.respond_to?(:to_ary)
            value.map { |v| ResourceObject.new(v) }
          else
            ResourceObject.new(value)
          end
        end
      end
    end
  end
end
