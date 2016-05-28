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

          return super unless datum[:hcp] == true && datum[:method] == :get && resource

          datum[:response] = {
            body:      resource.to_json,
            hcp:       true,
            headers:   content_type_header,
            remote_ip: '127.0.0.1',
            status:    200
          }

          super
        end

        private

        def resource
          @resource ||= embedded.find { |name, _| name == relation_name }.to_a[1]
        end

        def relation_name
          datum.dig(:hcp_params, :relation)
        end

        def embedded
          datum.dig(:hcp_params, :embedded).to_h
        end

        def content_type_header
          return {} unless (header = datum.dig(:hcp_params, :content_type))

          { 'Content-Type' => header }
        end
      end
    end
  end
end
