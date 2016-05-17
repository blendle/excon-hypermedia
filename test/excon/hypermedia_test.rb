# frozen_string_literal: true
# rubocop:disable Metrics/AbcSize, Metrics/LineLength
require_relative '../test_helper'

module Excon
  # HypermediaTest
  #
  # Verifies the Excon connection consuming HyperMedia APIs.
  #
  class HypermediaTest < Minitest::Test
    def entrypoint
      <<~EOF
        {
          "_links": {
            "hello": {
              "href":"http://www.example.com/hello/{location}"
            }
          }
        }
      EOF
    end

    def hello_world
      <<~EOF
        {
          "_links": {
            "goodbye": {
              "href":"http://www.example.com/hello/world/goodbye{?message}"
            }
          }
        }
      EOF
    end

    def hello_universe
      <<~EOF
        {
          "_links": {
            "goodbye": {
              "href":"http://www.example.com/hello/universe/goodbye{?message}"
            }
          }
        }
      EOF
    end

    def setup
      Excon.defaults[:mock] = true

      Excon.stub({ method: :get, path: '/api' }, body: entrypoint, status: 200)
      Excon.stub({ method: :get, path: '/hello/world' }, body: hello_world, status: 200)
      Excon.stub({ method: :get, path: '/hello/world/goodbye', query: nil }, body: 'bye!', status: 200)
      Excon.stub({ method: :get, path: '/hello/world/goodbye', query: 'message=farewell' }, body: 'farewell', status: 200)
      Excon.stub({ method: :get, path: '/hello/universe' }, body: hello_universe, status: 200)
    end

    def test_hypermedia_request
      conn = Excon.new('http://www.example.com/api', hypermedia: true)
      conn2 = conn.hello(expand: { location: 'world' })
      conn3 = conn.hello(expand: { location: 'universe' })

      assert_equal '/hello/world', conn2.data[:path]
      assert conn2.get.body.include?('http://www.example.com/hello/world/goodbye{?message}')

      assert_equal '/hello/universe', conn3.data[:path]
      assert conn3.get.body.include?('http://www.example.com/hello/universe/goodbye{?message}')
    end

    def test_nested_hypermedia_request
      conn = Excon.new('http://www.example.com/api', hypermedia: true)
      conn2 = conn.hello(expand: { location: 'world' }).goodbye
      conn3 = conn.hello(expand: { location: 'world' }).goodbye(expand: { message: 'farewell' })

      assert_equal '/hello/world/goodbye', conn2.data[:path]
      assert_nil conn2.data[:query]
      assert_equal 'bye!', conn2.get.body

      assert_equal '/hello/world/goodbye', conn3.data[:path]
      assert_equal 'message=farewell', conn3.data[:query]
      assert_equal 'farewell', conn3.get.body
    end

    def teardown
      Excon.stubs.clear
    end
  end
end
