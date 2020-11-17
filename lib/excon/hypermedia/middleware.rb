# frozen_string_literal: true

require 'backport_dig' if RUBY_VERSION < '2.3'

Excon.defaults[:middlewares].delete(Excon::Addressable::Middleware)
Excon.defaults[:middlewares].unshift(Excon::Addressable::Middleware)

# Excon
#
# We inject the `expand` key to the allowed lists of keys to be used when
# creating a request, or connection object. Excon does not enforce this yet, but
# it does print a warning, so this makes things future-proof.
module Excon
  VALID_REQUEST_KEYS.push(:hcp, :embedded, :hypermedia)
  VALID_CONNECTION_KEYS.push(:hcp, :embedded, :hypermedia)

  module HyperMedia
    # Middleware
    #
    # This middleware sets the `hypermedia` datum to `true`, if the returned
    # `Content-Type` header contains `hal+json`.
    #
    # If the `hypermedia` attribute is already set for the connection, it
    # will be left alone by this middleware.
    #
    class Middleware < Excon::Middleware::Base
      def request_call(datum)
        # if `hcp` is enabled, insert the `HypertextCachePattern` middleware in
        # the middleware stack right after this one.
        if datum[:hcp]
          orig_stack = @stack
          @stack = Excon::HyperMedia::Middlewares::HypertextCachePattern.new(orig_stack)
        end

        super
      end

      def response_call(datum)
        return super unless (headers = datum.dig(:response, :headers))
        return super unless (match = headers.find { |k, v| k.downcase == 'content-type' })
        content_type = match[1].to_s

        datum[:response][:hypermedia] = if datum[:hypermedia].nil?
          content_type.include?('hal+json')
        else
          datum[:hypermedia]
        end

        super
      end
    end
  end
end
