# frozen_string_literal: true
# rubocop:disable Metrics/MethodLength

require_relative '../test_helper'

module Excon
  # LinksTest
  #
  # Validate the workings of `Excon::HyperResource::Resource::Links`.
  #
  class LinksTest < Minitest::Test
    def body
      <<~EOF
        {
          "_links": {
            "self": {
              "href": "https://www.example.org/product/bicycle"
            },
            "parts": {
              "href": "https://www.example.org/product/bicycle/parts"
            }
          }
        }
      EOF
    end

    def data
      JSON.parse(body)
    end

    def links
      @links ||= Excon::HyperMedia::ResourceObject::Links.new(data['_links'])
    end

    def test_links
      assert_equal Excon::HyperMedia::ResourceObject::Links, links.class
    end

    def test_link_properties
      assert_equal %w(self parts), links.to_h.keys
    end
  end
end
