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
      def handle(method_name, *params) # rubocop:disable Metrics/CyclomaticComplexity
        return false unless enabled?

        case method_name
        when :resource                 then resource
        when :_links, :links           then resource._links
        when :_embedded, :embedded     then resource._embedded
        when :_properties, :properties then resource._properties
        when :rel                      then rel(params.shift, params)
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
        raise ArgumentError, 'missing relation name' unless name

        unless (link = resource._links[name])
          raise UnknownRelationError, "unknown relation: #{name}"
        end

        options = rel_params(params.first.to_h)

        link.respond_to?(:to_ary) ? link.map { |l| l.rel(options) } : link.rel(options)
      end

      def rel_params(params)
        params.merge(
          hcp: (params[:hcp].nil? ? response.data[:hcp] : params[:hcp]),
          embedded: resource._embedded.to_h,
          hypermedia: true
        )
      end
    end
  end
end
