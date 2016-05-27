# frozen_string_literal: true

require_relative '../test_helper'

module Excon
  # EdgeCaseTest
  #
  # Validate edge cases (or: non-happy path)
  #
  class EdgeCaseTest < HyperMediaTest
    def setup
      Excon.defaults[:mock] = true
      Excon.defaults[:middlewares].push(Excon::HyperMedia::Middleware)

      response = { headers: { 'Content-Type' => 'application/hal+json' } }
      Excon.stub({ path: '/api.json' }, response.merge(body: api_body))
      Excon.stub({ path: '/empty_json' }, response.merge(body: '{}'))
    end

    def teardown
      Excon.stubs.clear
      Excon.defaults[:middlewares].delete(Excon::HyperMedia::Middleware)
    end

    def api
      Excon.get('https://www.example.org/api.json')
    end

    def test_missing_middleware
      Excon.defaults[:middlewares].delete(Excon::HyperMedia::Middleware)

      assert_raises(NoMethodError) { api.rel }
    end

    def test_rel_missing_name
      ex = assert_raises(ArgumentError) { api.rel }
      assert_equal 'missing relation name', ex.message
    end

    def test_rel_missing_arguments
      assert_equal Excon::Connection, api.rel('self').class
    end

    def test_rel_unknown_relation
      ex = assert_raises(Excon::HyperMedia::UnknownRelationError) { api.rel('invalid') }
      assert_equal 'unknown relation: invalid', ex.message
    end

    def test_missing_links
      resource = Excon.get('https://www.example.org/empty_json').resource

      assert_equal({}, resource._links.to_h)
    end

    def test_missing_embedded
      resource = Excon.get('https://www.example.org/empty_json').resource

      assert_equal({}, resource._embedded.to_h)
    end

    def test_missing_properties
      resource = Excon.get('https://www.example.org/empty_json').resource

      assert_equal({}, resource._properties.to_h)
    end

    def test_unknown_property
      resource = Excon.get('https://www.example.org/api.json').resource

      assert_equal nil, resource._properties.invalid
      assert_equal nil, resource._properties['invalid']
    end

    def test_unknown_link
      resource = Excon.get('https://www.example.org/empty_json').resource

      assert_equal nil, resource._links.invalid
      assert_equal nil, resource._links['invalid']
    end

    def test_unknown_embed
      resource = Excon.get('https://www.example.org/api.json').resource

      assert_equal nil, resource._embedded.invalid
      assert_equal nil, resource._embedded['invalid']
    end
  end
end
