# frozen_string_literal: true

require 'excon/hypermedia/ext/response'

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
        return false if disabled? || resource.link(method_name).invalid?

        Excon.new(resource.link(method_name).uri, params.first.to_h.merge(hypermedia: true))
      end

      def resource
        @resource ||= Resource.new(response.body)
      end

      def enabled?
        response.data[:hypermedia] == true
      end

      def disabled?
        !enabled?
      end
    end
  end
end
