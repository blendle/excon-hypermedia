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

          if stubs.any?
            # We've created new stubs.  The request should be marked as `mocked`
            # to make sure the stubbed response is returned.
            datum[:mock] = true

            # The requested resource might not be part of the embedded resources
            # so we allow external requests.
            # datum[:allow_unstubbed_requests] = true

            # Make sure Excon's `Mock` middleware runs after this middleware, as
            # it might have already triggered in the middleware chain.
            orig_stack = @stack
            @stack = Excon::Middleware::Mock.new(orig_stack)
          end

          super
        rescue => e
          raise unless e.class == Excon::Errors::StubNotFound

          # If a request was made to a non-stubbed resource, don't use the Mock
          # middleware, but simply send the request to the server.
          @stack = orig_stack
          super
        end

        def response_call(datum)
          @datum = datum

          # After the response is returned, remove any request-specific stubs
          # from Excon, so they can't be accidentally re-used anymore.
          embedded.each { |r| (match = matcher(r)) && Excon.unstub(match) }

          super
        end

        private

        def stubs
          embedded.each { |r| (match = matcher(r)) && Excon.stub(match, response(r)) }.compact
        end

        def matcher(resource)
          return unless (uri = ::Addressable::URI.parse(resource.dig('_links', 'self', 'href')))

          {
            scheme: uri.scheme,
            host:   uri.host,
            path:   uri.path,
            query:  uri.query
          }
        end

        def response(resource)
          {
            body:      resource.to_json,
            hcp:       true,
            headers:   { 'Content-Type' => 'application/hal+json', 'X-HCP' => 'true' }
          }
        end

        def embedded
          datum[:embedded].to_h.values.flatten
        end
      end
    end
  end
end
