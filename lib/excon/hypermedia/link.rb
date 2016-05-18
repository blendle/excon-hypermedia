# frozen_string_literal: true

module Excon
  module HyperMedia
    # Link
    #
    # This HyperMedia::Link object encapsulates a link pointing to a resource.
    #
    class Link
      attr_reader :resource, :name

      def initialize(resource:, name:)
        @resource = resource
        @name     = name
      end

      def valid?
        link_data.keys.any?
      end

      def invalid?
        !valid?
      end

      def uri
        ::Addressable::URI.parse(href)
      end

      def href
        link_data['href']
      end

      private

      def link_data
        resource.links.fetch(name.to_s, {})
      end
    end
  end
end
