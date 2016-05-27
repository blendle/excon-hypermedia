# frozen_string_literal: true
# rubocop:disable Metrics/MethodLength

require_relative '../test_helper'

module Excon
  # LinkTest
  #
  # Validate the workings of `Excon::HyperResource::LinkObject`.
  #
  class LinkTest < Minitest::Test
    def self
      '{ "href": "https://www.example.org/hello" }'
    end

    def templated
      '{ "href": "https://www.example.org/hello/{receiver}", "templated": "true" }'
    end

    def full
      <<-EOF
        {
          "href": "https://www.example.org/goodbye/{receiver}",
          "templated": "true",
          "type": "json",
          "deprecation": true,
          "name": "goodbye",
          "profile": "https://profile.example.org",
          "title": "Goodbye!",
          "hreflang": "en-gb"
        }
      EOF
    end

    def data(name)
      JSON.parse(send(name))
    end

    def link(name)
      Excon::HyperMedia::LinkObject.new(data(name))
    end

    def test_link
      assert_equal data(:self), link(:self).to_h
    end

    def test_missing_property
      assert_raises(NoMethodError) { data(:self).name }
    end

    def test_href
      assert_equal data(:self)['href'], link(:self).href
    end

    def test_templated
      assert link(:templated).templated
    end

    def test_templated_returns_false_if_undefined
      refute link(:self).templated
    end

    def test_type
      assert_equal data(:full)['type'], link(:full).type
    end

    def test_deprecation
      assert_equal data(:full)['deprecation'], link(:full).deprecation
    end

    def test_name
      assert_equal data(:full)['name'], link(:full).name
    end

    def test_profile
      assert_equal data(:full)['profile'], link(:full).profile
    end

    def test_title
      assert_equal data(:full)['title'], link(:full).title
    end

    def test_hreflang
      assert_equal data(:full)['hreflang'], link(:full).hreflang
    end

    def test_uri
      assert_equal data(:self)['href'], link(:self).uri.to_s
    end
  end
end
