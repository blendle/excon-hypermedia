# frozen_string_literal: true

require_relative '../test_helper'

module Excon
  # HCPTest
  #
  # Validate the workings of `Excon::HyperResource::Middlewares::HypertextCachePattern`.
  #
  class HCPTest < HyperMediaTest
    def response
      @response ||= Excon.get('https://example.org/product/bicycle')
    end

    def test_non_hcp_response
      assert_equal nil, response[:hcp]
    end

    def test_hcp_response
      assert response.rel('pump', hcp: true).get[:hcp]
    end

    def test_hcp_response_with_missing_embedding
      api      = Excon.get('https://www.example.org/api.json')
      response = api.rel('product', expand: { uid: 'bicycle' }, rel: true).get

      assert_equal nil, response[:hcp]
    end

    def test_hcp_response_with_embedded_array
      wheels = response.rel('wheels', hcp: true)

      assert wheels.map(&:get).all? { |res| res[:hcp] }
    end

    def test_nested_hcp_responses
      pump = response.rel('pump', hcp: true).get
      response = pump.rel('parts', expand: { uid: 'bicycle' }).get

      assert response[:hcp]
    end

    def test_hcp_not_working_for_non_get_requests
      assert_equal nil, response.rel('pump', hcp: true).post[:hcp]
    end

    def test_hcp_resource
      resource = response.rel('pump', hcp: true).get.resource

      assert_equal Excon::HyperMedia::ResourceObject, resource.class
    end

    def test_hcp_links
      resource = response.rel('pump', hcp: true).get.resource

      assert_equal data(:parts)['_links']['self']['href'], resource._links.parts.href
    end
  end
end
