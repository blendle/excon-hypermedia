# frozen_string_literal: true

module Excon
  module HyperMedia
    # Link
    #
    # Encapsulates a link pointing to a resource.
    #
    # @see https://tools.ietf.org/html/draft-kelly-json-hal-08#section-5
    #
    class LinkObject
      include Collection

      # href
      #
      # The "href" property is REQUIRED.
      #
      # Its value is either a URI [RFC3986] or a URI Template [RFC6570].
      #
      # If the value is a URI Template then the Link Object SHOULD have a
      # "templated" attribute whose value is true.
      #
      # @see https://tools.ietf.org/html/draft-kelly-json-hal-08#section-5.1
      #
      def href
        to_property!(:href)
      end

      # The "templated" property is OPTIONAL.
      #
      # Its value is boolean and SHOULD be true when the Link Object's "href"
      # property is a URI Template.
      #
      # Its value SHOULD be considered false if it is undefined or any other
      # value than true.
      #
      # @see: https://tools.ietf.org/html/draft-kelly-json-hal-08#section-5.2
      #
      def templated
        to_property(__method__) || false
      end

      # type
      #
      # The "type" property is OPTIONAL.
      #
      # Its value is a string used as a hint to indicate the media type
      # expected when dereferencing the target resource.
      #
      # @see: https://tools.ietf.org/html/draft-kelly-json-hal-08#section-5.3
      #
      def type
        to_property!(__method__)
      end

      # deprecation
      #
      # The "deprecation" property is OPTIONAL.
      #
      # Its presence indicates that the link is to be deprecated (i.e.
      # removed) at a future date.  Its value is a URL that SHOULD provide
      # further information about the deprecation.
      #
      # A client SHOULD provide some notification (for example, by logging a
      # warning message) whenever it traverses over a link that has this
      # property.  The notification SHOULD include the deprecation property's
      # value so that a client manitainer can easily find information about
      # the deprecation.
      #
      # @see https://tools.ietf.org/html/draft-kelly-json-hal-08#section-5.4
      #
      def deprecation
        to_property!(__method__)
      end

      # name
      #
      # The "name" property is OPTIONAL.
      #
      # Its value MAY be used as a secondary key for selecting Link Objects
      # which share the same relation type.
      #
      # @see https://tools.ietf.org/html/draft-kelly-json-hal-08#section-5.5
      #
      def name
        to_property!(__method__)
      end

      # profile
      #
      # The "profile" property is OPTIONAL.
      #
      # Its value is a string which is a URI that hints about the profile (as
      # defined by [I-D.wilde-profile-link]) of the target resource.
      #
      # @see https://tools.ietf.org/html/draft-kelly-json-hal-08#section-5.6
      #
      def profile
        to_property!(__method__)
      end

      # title
      #
      # The "title" property is OPTIONAL.
      #
      # Its value is a string and is intended for labelling the link with a
      # human-readable identifier (as defined by [RFC5988]).
      #
      # @see https://tools.ietf.org/html/draft-kelly-json-hal-08#section-5.7
      #
      def title
        to_property!(__method__)
      end

      # hreflang
      #
      # The "hreflang" property is OPTIONAL.
      #
      # Its value is a string and is intended for indicating the language of
      # the target resource (as defined by [RFC5988]).
      #
      # @see https://tools.ietf.org/html/draft-kelly-json-hal-08#section-5.8
      #
      def hreflang
        to_property!(__method__)
      end

      # uri
      #
      # Returns a URI representation of the provided "href" property.
      #
      # @return [URI] URI object of the "href" property
      #
      def uri
        ::Addressable::URI.parse(href)
      end

      # rel
      #
      # Returns an `Excon::Connection` instance, based on the current link.
      #
      # @return [Excon::Connection] Connection object based on current link
      #
      def rel(params = {})
        Excon.new(href, params)
      end

      private

      def property(value)
        value
      end
    end
  end
end
