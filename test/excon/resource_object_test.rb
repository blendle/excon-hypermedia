# frozen_string_literal: true
# rubocop:disable Metrics/MethodLength

require_relative '../test_helper'

module Excon
  # ResourceObjectTest
  #
  # Validate the workings of `Excon::HyperResource::ResourceObject`.
  #
  class ResourceObjectTest < Minitest::Test
    def body
      <<-EOF
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
      @resource ||= Excon::HyperMedia::ResourceObject.new(data)
    end

    def test_resource
      assert_equal data, resource.instance_variable_get(:@data)
    end

    def test_links
      assert_equal data['_links']['hello']['href'], resource._links.hello.href
    end

    def test_properties
      assert_equal 'universe', resource.uid
      assert_equal 'world', resource.hello
      assert_equal 'world', resource['hello']
      assert_equal nil, resource['invalid']
    end
  end
end
