# frozen_string_literal: true
require_relative '../test_helper'

module Excon
  # LinkTest
  #
  # Validate the workings of `Excon::HyperResource::Link`.
  #
  class LinkTest < Minitest::Test
    def body # rubocop:disable Metrics/MethodLength
      <<~EOF
        {
          "_links": {
            "hello": {
              "href": "http://www.example.com/hello/{location}"
            }
          },
          "uid": "universe",
          "hello": "world"
        }
      EOF
    end

    def data
      JSON.parse(body)
    end

    def link
      @link ||= Excon::HyperMedia::Link.new(name: 'hello', hash: data)
    end

    def invalid_link
      @invalid_link ||= Excon::HyperMedia::Link.new(name: 'goodbye', hash: data)
    end

    def test_link
      assert_equal link.name, 'hello'
    end

    def test_valid_link
      assert link.valid?
    end

    def test_invalid_link
      refute invalid_link.valid?
    end

    def test_uri
      assert_equal link.uri.to_s, data['_links']['hello']['href']
    end

    def test_href
      assert_equal link.href, data['_links']['hello']['href']
    end
  end
end
