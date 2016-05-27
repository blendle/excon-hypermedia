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

        case method_name
        when :resource then resource
        when :rel      then rel(params.shift, params)
        else false
        end
      end

      private

      attr_reader :response

      def resource
        @resource ||= ResourceObject.new(body_to_hash)
      end

      def body_to_hash
        (content_type =~ %r{application/(hal\+)?json}).nil? ? {} : JSON.parse(response.body)
      end

      def content_type
        response.headers['Content-Type'].to_s
      end

      def enabled?
        response.data[:hypermedia] == true
      end

      def rel(name, params)
        link    = resource._links.send(name)
        options = params.first.to_h.merge(hypermedia: true)

        link.respond_to?(:to_ary) ? link.map { |l| l.rel(options) } : link.rel(options)
      end
    end
  end
end
