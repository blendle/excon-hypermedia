# frozen_string_literal: true

Excon.defaults[:middlewares].delete(Excon::Addressable::Middleware)
Excon.defaults[:middlewares].unshift(Excon::Addressable::Middleware)

module Excon
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
        return super unless (content_type = datum.dig(:response, :headers, 'Content-Type').to_s)

        datum[:response] ||= {}
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
