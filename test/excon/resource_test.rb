# frozen_string_literal: true
require_relative '../test_helper'

module Excon
  # ResourceTest
  #
  # Validate the workings of `Excon::HyperResource::Resource`.
  #
  class ResourceTest < Minitest::Test
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
      @data ||= JSON.parse(body)
    end

    def resource
      @resource ||= Excon::HyperMedia::Resource.new(body)
    end

    def test_resource
      assert_equal data, resource.data
    end

    def test_links
      assert_equal data['_links']['hello']['href'], resource.links.first.href
    end

    def test_attributes
      assert resource.attributes.key?('uid')
      assert resource.attributes.key?('hello')

      refute resource.attributes.key?('_links')
    end
  end
end
