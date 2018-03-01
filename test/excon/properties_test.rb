# frozen_string_literal: true

require_relative '../test_helper'

module Excon
  # PropertiesTest
  #
  # Validate the workings of `Excon::HyperResource::Resource::Properties`.
  #
  class PropertiesTest < Minitest::Test
    def body
      <<-JSON
        {
          "size": "49CM",
          "bike-type": "Mountain Bike",
          "derailleurs": {
            "front": 3,
            "back": 7
          },
          "reflectors": true,
          "BMX": false
        }
      JSON
    end

    def data
      JSON.parse(body)
    end

    def properties
      @properties ||= Excon::HyperMedia::ResourceObject::Properties.new(data)
    end

    def test_properties
      assert_equal data, properties.to_h
    end

    def test_attribute
      assert_equal properties.size, '49CM'
    end

    def test_boolean_attribute
      assert_equal properties.reflectors, true
    end

    def test_uppercase_attribute_names
      assert_equal properties.bmx, false
      assert_equal properties['BMX'], false
    end

    def test_invalid_attribute_names
      refute properties.respond_to?('bike-type')
      assert_equal properties['bike-type'], 'Mountain Bike'
    end

    def test_nested_attribute
      assert_equal properties.derailleurs.front, 3
      assert_equal properties.derailleurs.back, 7
      assert_equal properties['derailleurs'].back, 7
    end

    def test_nested_attribute_hash
      assert_equal properties.derailleurs.to_h, data['derailleurs']
    end
  end
end
