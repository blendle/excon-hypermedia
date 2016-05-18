# frozen_string_literal: true
# rubocop:disable Metrics/LineLength
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
      response = client.hello(expand: { location: 'world' }).get

      assert response.body.include?('http://www.example.com/hello/world/goodbye{?message}')
    end

    def test_nested_request
      hello    = client.hello(expand: { location: 'world' })
      response = hello.get.goodbye.get

      assert_equal 'bye!', response.body
    end

    def test_nested_query_parameters
      hello    = client.hello(expand: { location: 'world' })
      response = hello.get.goodbye(expand: { message: 'farewell' }).get

      assert_equal 'farewell', response.body
    end

    def test_expand_in_get
      response = client.hello.get(expand: { location: 'world' })

      assert response.body.include?('http://www.example.com/hello/world/goodbye{?message}')
    end

    def test_links
      response = client.hello(expand: { location: 'world' }).get

      assert_equal response.links.first.name, 'goodbye'
    end

    def test_link
      response = client.hello(expand: { location: 'world' }).get

      assert_equal response.link('goodbye').name, 'goodbye'
    end

    def test_attributes
      response = client.hello(expand: { location: 'world' }).get

      assert_equal response.attributes.to_h, uid: 'hello', message: 'goodbye!'
      assert_equal response.attributes.uid, 'hello'
    end

    def teardown
      Excon.stubs.clear
    end
  end
end
