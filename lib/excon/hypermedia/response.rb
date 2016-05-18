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
      def initialize(response)
        @response = response
      end

      # handle
      #
      # Correctly handle the hypermedia request.
      #
      def handle(method_name, *params)
        return false unless enabled?

        if resource.type?(method_name) == :link
          handle_link(method_name, params)
        elsif resource.respond_to?(method_name, false)
          resource.send(method_name, *params)
        else
          false
        end
      end

      private

      attr_reader :response

      def resource
        @resource ||= Resource.new(response.body)
      end

      def enabled?
        response.data[:hypermedia] == true
      end

      def handle_link(name, params)
        Excon.new(resource.link(name).href, params.first.to_h.merge(hypermedia: true))
      end
    end
  end
end
