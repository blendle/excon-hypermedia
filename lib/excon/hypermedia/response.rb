# frozen_string_literal: true
require 'excon/hypermedia/ext/response'
require 'json'

module Excon
  module HyperMedia
    # Response
    #
    # This HyperMedia::Response object helps determine valid subsequent
    # requests and attribute values.
    #
    class Response
      attr_reader :response

      def initialize(response)
        @response = response
      end

      # handle
      #
      # Correctly handle the hypermedia request.
      #
      def handle(method_name, *params)
        return false if disabled? || !valid_response?(method_name)

        Excon.new(uri(method_name), params.first.to_h.merge(hypermedia: true))
      end

      def enabled?
        response.data[:hypermedia] == true
      end

      def disabled?
        !enabled?
      end

      def valid_response?(resource)
        !resource_link(resource).nil?
      end

      def resource_link(resource)
        data.dig('_links', resource.to_s, 'href')
      end

      def uri(resource)
        ::Addressable::URI.parse(resource_link(resource))
      end

      def data
        @data ||= JSON.parse(response.body)
      rescue JSON::ParserError
        {}
      end
    end
  end
end
