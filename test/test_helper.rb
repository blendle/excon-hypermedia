# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'excon/hypermedia'
require 'minitest/autorun'
require 'open4'
require_relative 'support/responses'

Excon.defaults.merge!(
  connect_timeout: 1,
  read_timeout: 1,
  write_timeout: 1
)

@server_pid, _, _, e = Open4.popen4(File.expand_path('support/server.rb', __dir__))
until e.gets =~ /HTTPServer#start/; end

Minitest.after_run do
  Process.kill(9, @server_pid)
  Process.wait(@server_pid)
end

module Excon
  # HyperMediaTest
  #
  class HyperMediaTest < Minitest::Test
    def api
      Excon.get('http://localhost:8000/api.json')
    end

    def api_v2
      Excon.get('http://localhost:8000/api_v2.json', hypermedia: true)
    end

    def empty_json_response
      Excon.get('http://localhost:8000/empty_json')
    end

    def bicycle
      @bicycle ||= Excon.get('http://localhost:8000/product/bicycle')
    end

    def setup
      Excon.defaults[:middlewares].push(Excon::HyperMedia::Middleware)
    end

    def teardown
      Excon.defaults[:middlewares].delete(Excon::HyperMedia::Middleware)
    end

    def data(name)
      JSON.parse(Test::Response.send("#{name}_body"))
    end

    def url(path)
      File.join('http://localhost:8000', path)
    end
  end
end
