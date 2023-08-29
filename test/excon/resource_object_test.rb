# frozen_string_literal: true

require_relative '../test_helper'

module Excon
  # ResourceObjectTest
  #
  # Validate the workings of `Excon::HyperResource::ResourceObject`.
  #
  class ResourceObjectTest < Minitest::Test
    def body
      <<-JSON
        {
          "_links": {
            "hello": {
              "href": "https://example.org/hello/{location}"
            }
          },
          "uid": "universe",
          "hello": "world"
        }
      JSON
    end

    def data
      @data ||= JSON.parse(body)
    end

    def resource
      @resource ||= Excon::HyperMedia::ResourceObject.new(data)
    end

    def test_resource
      assert_equal data, resource.data
    end

    def test_links
      assert_equal data['_links']['hello']['href'], resource._links.hello.href
    end

    def test_properties
      assert_equal 'universe', resource.uid
      assert_equal 'world', resource.hello
      assert_equal 'world', resource['hello']
      assert_nil resource['invalid']
    end

    def test_correctly_raising_no_method_error
      assert_raises(NoMethodError) { resource.invalid }
    end

    def test_correctly_respond_to
      assert_equal true, resource.respond_to?(:hello)
      assert_equal false, resource.respond_to?(:invalid)
    end
  end
end
