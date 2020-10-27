# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/LineLength

require_relative '../test_helper'

module Excon
  class MiddlewareTest < Minitest::Test
    def setup
      Excon.defaults[:mock] = true
      Excon.stub(
        { :path => '/lowercase-content-type' },
        {
          headers: { 'content-type' => 'application/hal+json' },
          body:    '{}',
          status:  200
        }
      )
      Excon.stub(
        { :path => '/uppercase-content-type' },
        {
          headers: { 'Content-Type' => 'application/hal+json' },
          body:    '{}',
          status:  200
        }
      )
    end

    def test_request_with_lowercase_content_type
      test = Excon.get(
        'http://example.com',
        path: '/lowercase-content-type',
        middlewares: Excon.defaults[:middlewares] + [Excon::HyperMedia::Middleware]
      )

      assert test.data[:hypermedia]
    end

    def test_request_with_uppercase_content_type
      test = Excon.get(
        'http://example.com',
        path: '/uppercase-content-type',
        middlewares: Excon.defaults[:middlewares] + [Excon::HyperMedia::Middleware]
      )

      assert test.data[:hypermedia]
    end

    def teardown
      Excon.stubs.clear
      Excon.defaults[:mock] = false
    end
  end
end

# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/LineLength
