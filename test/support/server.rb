#!/usr/bin/env ruby
# frozen_string_literal: true

require 'webrick'
require 'logger'
require_relative 'responses'

server = WEBrick::HTTPServer.new(Port: 8000, Logger: Logger.new(STDERR))

def body(name)
  Test::Response.send("#{name}_body")
end

endpoints = {
  '/empty_json' => { body: '{}' },
  '/api.json' => { body: body(:api) },
  '/product/bicycle' => { body: body(:bicycle) },
  '/product/bicycle/wheels/front' => { body: body(:front_wheel) },
  '/product/bicycle/wheels/rear' => { body: body(:rear_wheel) },
  '/product/pump' => { body: body(:pump) },
  '/product/pump/parts' => { body: body(:parts) },
  '/product/handlebar' => { body: body(:handlebar) },
  '/api_v2.json' => { body: body(:api), headers: { 'Content-Type' => 'application/json' } }
}

endpoints.each do |path, params|
  server.mount_proc(path) do |_, response|
    response['Content-Type'] = 'application/hal+json'
    params[:headers].to_h.each { |k, v| response[k] = v }

    response.body = params[:body]
  end
end

server.start
