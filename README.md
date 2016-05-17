# Excon::Hypermedia

Teaches [Excon][] how to talk to [HyperMedia APIs][hypermedia].

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'excon-hypermedia'
```

And then execute:

```shell
bundle
```

Or install it yourself as:

```shell
gem install excon-hypermedia
```

## Usage

**NOTE**: This library is in very early development. Right now, it only talks
the `HAL/JSON` protocol, and it only knows how to follow (non-curie) link
relations. It returns raw response bodies in string format.

This gem adds a thin layer on top of [Excon][excon] to make it talk with an
HyperMedia-enabled API. To let Excon know the connection supports HyperMedia,
simply add the `hypermedia: true` option.

```ruby
conn = Excon.new('http://www.example.com/api.json', hypermedia: true)
conn.class # => Excon::Connection
```

From that point on, you can use this single connection to make all requests. The
`hypermedia` option will be passed on to all subsequent connection objects, as
long as you keep chaining the requests from the original top-level connection.

```ruby
product = conn.product(expand: { uid: 'hello' })
product.class # => Excon::Connection

response = product.get
response.class # => Excon::Response
response.body.class # => String
```

As seen above, you can expand URI Template variables using the `expand` option,
provided by the [`excon-addressable` library][excon-addressable].

You can mark any connection object as hypermedia-aware – not just the top-level
entrypoint – by passing in the `hypermedia: true` option:

```ruby
user = Excon.new('http://www.example.com/users/jeanmertz', hypermedia: true)
user.orders.class # => Excon::Connection
```

Since each new resource is simply an `Excon::Connection` object, all
[Excon-provided options][options] are available as well:

```ruby
product.get(idempotent: true, retry_limit: 6)
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## TODO

* use Excon's Middleware system
* make it easy to access attributes in response objects
* properly handle curied-links and/or non-valid Ruby method name links
* work correctly with Excon.get/post/delete shortcut methods

[excon]: https://github.com/excon/excon
[hypermedia]: https://en.wikipedia.org/wiki/HATEOAS
[excon-addressable]: https://github.com/JeanMertz/excon-addressable
[options]: https://github.com/excon/excon#options
