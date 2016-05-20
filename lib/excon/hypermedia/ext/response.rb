# frozen_string_literal: true

module Excon
  module HyperMedia
    module Ext
      # Ext::Response
      #
      # Overloads the default `Excon::Response` to add a thin HyperMedia layer
      # on top.
      #
      module Response
        private

        def method_missing(method_name, *params)
          hypermedia_response.handle(method_name, *params) || super
        end

        def respond_to_missing?(method_name, include_private = false)
          hypermedia_response.handle(method_name, *params) != false || super
        end

        def hypermedia_response
          @hypermedia_response ||= HyperMedia::Response.new(self)
        end
      end
    end
  end

  # :nodoc:
  class Response
    prepend HyperMedia::Ext::Response
  end
end
