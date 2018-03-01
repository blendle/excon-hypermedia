# frozen_string_literal: true

require_relative '../test_helper'

module Excon
  # EdgeCaseTest
  #
  # Validate edge cases (or: non-happy path)
  #
  class EdgeCaseTest < HyperMediaTest
    def empty_json_resource
      empty_json_response.resource
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
      assert_equal({}, empty_json_resource._links.to_h)
    end

    def test_missing_embedded
      assert_equal({}, empty_json_resource._embedded.to_h)
    end

    def test_missing_properties
      assert_equal({}, empty_json_resource._properties.to_h)
    end

    def test_unknown_property
      assert_nil api.resource._properties.invalid
      assert_nil api.resource._properties['invalid']
    end

    def test_unknown_property_respond_to
      assert_equal false, api.resource._properties.respond_to?(:invalid)
    end

    def test_unknown_link
      assert_nil empty_json_resource._links.invalid
      assert_nil empty_json_resource._links['invalid']
    end

    def test_unknown_embed
      assert_nil api.resource._embedded.invalid
      assert_nil api.resource._embedded['invalid']
    end
  end
end
