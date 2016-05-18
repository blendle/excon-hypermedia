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
        return false if disabled?

        case resource.type?(method_name)
        when :link      then return handle_link(method_name, params)
        when :attribute then return handle_attribute(method_name)
        end

        resource.respond_to?(method_name) ? resource.send(method_name, *params) : false
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

      private

      def handle_link(name, params)
        Excon.new(resource.link(name).href, params.first.to_h.merge(hypermedia: true))
      end

      def handle_attribute(name)
        resource.attributes[name.to_s]
      end
    end
  end
end
