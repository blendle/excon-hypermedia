# frozen_string_literal: true

require_relative '../test_helper'

module Excon
  # ResourceObjectTest
  #
  # Validate the workings of `Excon::HyperResource::ResourceObject`.
  #
  class ResponseTest < HyperMediaTest
    def response
      bicycle
    end

    def test_response
      assert_equal Excon::Response, response.class
    end

    def test_links
      assert_equal response.resource._links, response.links
      assert_equal response.resource._links, response._links
    end

    def test_embedded
      assert_equal response.resource._embedded, response.embedded
      assert_equal response.resource._embedded, response._embedded
    end

    def test_properties
      assert_equal response.resource._properties, response.properties
      assert_equal response.resource._properties, response._properties
    end
  end
end
