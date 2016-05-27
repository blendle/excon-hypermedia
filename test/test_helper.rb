# frozen_string_literal: true
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/LineLength
# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'excon/hypermedia'
require 'minitest/autorun'

module Excon
  # HyperMediaTest
  #
  class HyperMediaTest < Minitest::Test
    def setup
      Excon.defaults[:mock] = true
      Excon.defaults[:middlewares].push(Excon::HyperMedia::Middleware)

      response = { headers: { 'Content-Type' => 'application/hal+json' } }
      Excon.stub({ method: :get, path: '/api.json' }, response.merge(body: api_body))
      Excon.stub({ method: :get, path: '/product/bicycle' }, response.merge(body: bicycle_body))
      Excon.stub({ method: :get, path: '/product/bicycle/wheels/front' }, response.merge(body: front_wheel_body))
      Excon.stub({ method: :get, path: '/product/bicycle/wheels/rear' }, response.merge(body: rear_wheel_body))
      Excon.stub({ method: :get, path: '/product/pump' }, response.merge(body: pump_body))
      Excon.stub({ method: :get, path: '/product/handlebar' }, response.merge(body: handlebar_body))
      Excon.stub({ method: :get, path: '/api_v2.json' }, body: api_body, headers: { 'Content-Type' => 'application/json' })
    end

    def teardown
      Excon.stubs.clear
      Excon.defaults[:middlewares].delete(Excon::HyperMedia::Middleware)
      Excon.defaults[:mock] = true
    end

    def data(name)
      JSON.parse(send("#{name}_body"))
    end

    def api_body
      <<-EOF
       {
         "_links": {
           "self": {
             "href": "https://www.example.org/api.json"
           },
           "product": {
             "href": "https://www.example.org/product/{uid}",
             "templated": true
           }
         }
       }
     EOF
    end

    def bicycle_body
      <<-EOF
        {
          "_links": {
            "self": {
              "href": "https://www.example.org/product/bicycle"
            },
            "handlebar": {
              "href": "https://www.example.org/product/handlebar"
            },
            "object_id": {
              "href": "https://www.example.org/product/bicycle/object_id_as_text"
            },
            "pump": {
              "href": "https://www.example.org/product/pump"
            },
            "wheels": [
              { "href": "https://www.example.org/product/bicycle/wheels/front" },
              { "href": "https://www.example.org/product/bicycle/wheels/rear" }
            ]
          },
          "bike-type": "Mountain Bike",
          "BMX": false,
          "derailleurs": {
            "back": 7,
            "front": 3
          },
          "name": "bicycle",
          "reflectors": true,
          "_embedded": {
            "pump": #{pump_body},
            "wheels": [#{front_wheel_body}, #{rear_wheel_body}]
          }
        }
      EOF
    end

    def handlebar_body
      <<-EOF
        {
          "_links": {
            "self": {
              "href": "https://www.example.org/product/handlebar"
            }
          },
          "material": "Carbon fiber",
          "reach": "75mm",
          "bend": "compact"
        }
      EOF
    end

    def pump_body
      <<-EOF
        {
          "_links": {
            "self": {
              "href": "https://www.example.org/product/pump"
            }
          },
          "weight": "2kg",
          "type": "Floor Pump",
          "valve-type": "Presta"
        }
      EOF
    end

    def rear_wheel_body
      <<-EOF
        {
          "_links": {
            "self": {
              "href": "https://www.example.org/product/bicycle/wheels/rear"
            }
          },
          "position": "rear",
          "lacing_pattern": "Radial"
        }
      EOF
    end

    def front_wheel_body
      <<-EOF
        {
          "_links": {
            "self": {
              "href": "https://www.example.org/product/bicycle/wheels/front"
            }
          },
          "position": "front",
          "lacing_pattern": "Radial/2-Cross"
        }
      EOF
    end
  end
end
