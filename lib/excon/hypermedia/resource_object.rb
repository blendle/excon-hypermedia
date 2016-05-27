# frozen_string_literal: true

require 'excon/hypermedia/resource_object/embedded'
require 'excon/hypermedia/resource_object/links'
require 'excon/hypermedia/resource_object/properties'

module Excon
  module HyperMedia
    # ResourceObject
    #
    # Represents a resource.
    #
    class ResourceObject
      RESERVED_PROPERTIES = %w(_links _embedded).freeze

      def initialize(data)
        @data = data
      end

      def _properties
        @_properties ||= Properties.new(@data.reject { |k, _| RESERVED_PROPERTIES.include?(k) })
      end

      # _links
      #
      # The reserved "_links" property is OPTIONAL.
      #
      # It is an object whose property names are link relation types (as
      # defined by [RFC5988]) and values are either a Link Object or an array
      # of Link Objects.  The subject resource of these links is the Resource
      # Object of which the containing "_links" object is a property.
      #
      # @see https://tools.ietf.org/html/draft-kelly-json-hal-08#section-4.1.1
      #
      def _links
        @_links ||= Links.new(@data['_links'])
      end

      # _embedded
      #
      # The reserved "_embedded" property is OPTIONAL
      #
      # It is an object whose property names are link relation types (as
      # defined by [RFC5988]) and values are either a Resource Object or an
      # array of Resource Objects.
      #
      # Embedded Resources MAY be a full, partial, or inconsistent version of
      # the representation served from the target URI.
      #
      # @see https://tools.ietf.org/html/draft-kelly-json-hal-08#section-4.1.2
      #
      def _embedded
        @_embedded ||= Embedded.new(@data['_embedded'])
      end

      def [](key)
        _properties[key]
      end

      def method_missing(method_name, *_)
        _properties.send(method_name)
      end
    end
  end
end
