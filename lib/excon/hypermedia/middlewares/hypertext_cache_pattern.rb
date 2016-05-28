# frozen_string_literal: true

module Excon
  module HyperMedia
    module Middlewares
      # HypertextCachePattern
      #
      # This middleware handles hcp-enabled requests.
      #
      # @see: https://tools.ietf.org/html/draft-kelly-json-hal-06#section-8.3
      #
      class HypertextCachePattern < Excon::Middleware::Base
        attr_reader :datum

        def request_call(datum)
          @datum = datum

          return super unless datum[:hcp] == true && datum[:method] == :get && find_embedded

          datum[:response] = {
            body:      @embedded.to_json,
            hcp:       true,
            headers:   content_type_header,
            remote_ip: '127.0.0.1',
            status:    200
          }

          super
        end

        private

        def find_embedded
          datum.dig(:hcp_params, :embedded).to_h.each do |_, object|
            break if (@embedded = object_to_embedded(object))
          end

          @embedded
        end

        def object_to_embedded(object)
          uri = ::Addressable::URI.new(datum.tap { |h| h.delete(:port) })

          if object.respond_to?(:to_ary)
            object.find { |hash| hash.dig('_links', 'self', 'href') == uri.to_s }
          elsif object.dig('_links', 'self', 'href') == uri.to_s
            object
          end
        end

        def content_type_header
          return {} unless (header = datum.dig(:hcp_params, :content_type))

          { 'Content-Type' => header }
        end
      end
    end
  end
end
