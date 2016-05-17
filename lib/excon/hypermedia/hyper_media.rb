# frozen_string_literal: true
require 'json'

module Excon
  # HyperMedia
  #
  module HyperMedia
    def method_missing(method_name, *params)
      return super unless (url = entrypoint.dig('_links', method_name.to_s, 'href'))

      Excon.new(url, params.first.to_h.merge(hypermedia: true))
    end

    def respond_to_missing?(method_name, include_private = false)
      entrypoint.dig('_links', method_name.to_s, 'href') ? true : super
    end

    private

    def entrypoint
      @entrypoint ||= JSON.parse(get.body)
    rescue JSON::ParserError
      {}
    end
  end
end
