# frozen_string_literal: true
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/LineLength

require_relative '../test_helper'

module Excon
  # IntegrationTest
  #
  # Verifies the Excon connection consuming HyperMedia APIs.
  #
  class IntegrationTest < HyperMediaTest
    def api
      Excon.get('https://www.example.org/api.json')
    end

    def test_request
      response = api.rel('product', expand: { uid: 'bicycle' }).get

      assert response.body.include?('https://www.example.org/product/bicycle')
    end

    def test_request_using_link_rel
      response = api.resource._links.product.rel(expand: { uid: 'bicycle' }).get

      assert response.body.include?('https://www.example.org/product/bicycle')
    end

    def test_nested_request
      bicycle  = api.rel('product', expand: { uid: 'bicycle' }).get
      response = bicycle.rel('handlebar').get

      assert_equal data(:handlebar)['material'], response.resource.material
    end

    def test_collection_request
      bicycle   = api.rel('product', expand: { uid: 'bicycle' }).get
      wheels    = bicycle.rel('wheels')
      responses = wheels.map(&:get)

      assert Array, wheels.class
      assert_equal data(:front_wheel)['position'], responses.first.resource.position
    end

    def test_expand_in_get
      response = api.rel('product').get(expand: { uid: 'bicycle' })

      assert response.body.include?('https://www.example.org/product/bicycle')
    end

    def test_invalid_relation
      assert_raises(NoMethodError) { api.rel('invalid') }
    end

    def test_link
      response = api.rel('product', expand: { uid: 'bicycle' }).get

      assert_equal data(:bicycle)['_links']['handlebar']['href'], response.resource._links.handlebar.href
    end

    def test_link_collection
      response = api.rel('product', expand: { uid: 'bicycle' }).get

      assert_equal Array, response.resource._links.wheels.class
      assert_equal data(:bicycle)['_links']['wheels'][0]['href'], response.resource._links.wheels.first.href
    end

    def test_nested_attributes
      response = api.rel('product', expand: { uid: 'bicycle' }).get

      assert_equal 7, response.resource.derailleurs.back
    end

    def test_invalid_attribute
      response = api.rel('product', expand: { uid: 'bicycle' }).get

      assert_equal 'Mountain Bike', response.resource['bike-type']
      assert_equal false, response.resource.bmx
    end

    def test_embedded_resource
      response = api.rel('product', expand: { uid: 'bicycle' }).get

      assert_equal Excon::HyperMedia::ResourceObject, response.resource._embedded.pump.class
      assert_equal '2kg', response.resource._embedded.pump.weight
    end

    def test_embedded_resource_collection
      response = api.rel('product', expand: { uid: 'bicycle' }).get

      assert_equal Array, response.resource._embedded.wheels.class
      assert_equal data(:front_wheel)['position'], response.resource._embedded.wheels.first.position
    end

    def test_request_with_json_content_type
      api      = Excon.get('https://www.example.org/api_v2.json', hypermedia: true)
      response = api.rel('product', expand: { uid: 'bicycle' }).get

      assert response.body.include?('https://www.example.org/product/bicycle')
    end

    def teardown
      Excon.stubs.clear
    end
  end
end
