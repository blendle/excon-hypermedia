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
      '{ "_links": { "hello": { "href":"http://www.example.com/hello/{location}" } } }'
    end

    def hello_world # rubocop:disable Metrics/MethodLength
      <<~EOF
        {
          "_links": {
            "goodbye": {
              "href":"http://www.example.com/hello/world/goodbye{?message}"
            }
          },
          "uid": "hello",
          "message": "goodbye!"
        }
        EOF
    end

    def setup
      Excon.defaults[:mock] = true
      Excon.defaults[:middlewares].push(Excon::HyperMedia::Middleware)

      response = { headers: { 'Content-Type' => 'application/hal+json' } }
      Excon.stub({ method: :get, path: '/api' }, response.merge(body: entrypoint))
      Excon.stub({ method: :get, path: '/hello/world' }, response.merge(body: hello_world))
      Excon.stub({ method: :get, path: '/hello/world/goodbye', query: nil }, response.merge(body: 'bye!'))
      Excon.stub({ method: :get, path: '/hello/world/goodbye', query: 'message=farewell' }, response.merge(body: 'farewell'))
    end

    def client
      Excon.get('http://www.example.com/api')
    end

    def test_request
      connection = client.hello(expand: { location: 'world' })
      response   = connection.get

      assert_equal Excon::Connection, connection.class
      assert_equal '/hello/world', connection.data[:path]
      assert response.body.include?('http://www.example.com/hello/world/goodbye{?message}')
    end

    def test_nested_request
      hello      = client.hello(expand: { location: 'world' })
      connection = hello.get.goodbye
      response   = connection.get

      assert_equal Excon::Connection, connection.class
      assert_equal '/hello/world/goodbye', connection.data[:path]
      assert_equal 'bye!', response.body
    end

    def test_nested_query_parameters
      hello      = client.hello(expand: { location: 'world' })
      connection = hello.get.goodbye(expand: { message: 'farewell' })
      response   = connection.get

      assert_equal Excon::Connection, connection.class
      assert_equal '/hello/world/goodbye', connection.data[:path]
      assert_equal 'message=farewell', connection.data[:query]
      assert_equal 'farewell', response.body
    end

    def test_attribute
      connection = client.hello(expand: { location: 'world' })
      response   = connection.get

      assert_equal response.uid, 'hello'
      assert_equal response.message, 'goodbye!'
    end

    def test_links
      response = client.hello(expand: { location: 'world' }).get

      assert_equal response.links.first.name, 'goodbye'
    end

    def teardown
      Excon.stubs.clear
    end
  end
end
