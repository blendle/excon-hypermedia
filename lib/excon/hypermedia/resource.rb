# frozen_string_literal: true

require 'json'

module Excon
  module HyperMedia
    # Resource
    #
    # This HyperMedia::Resource object encapsulates the returned JSON and
    # makes it easy to access the links and attributes.
    #
    class Resource
      attr_reader :data

      def initialize(body)
        @body = body
      end

      def links
        data.fetch('_links', {})
      end

      def link(link_name)
        Link.new(resource: self, name: link_name)
      end

      def attributes
        data.reject do |k, _|
          k == '_links'
        end
      end

      def type?(name)
        return :link if link(name).valid?
        return :attribute if attributes.keys.include?(name.to_s)

        :unknown
      end

      def data
        @data ||= JSON.parse(@body)
      rescue JSON::ParserError
        {}
      end
    end
  end
end
