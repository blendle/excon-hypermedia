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
simply enable the correct middleware (either globally, or per-connection):

```ruby
Excon.defaults[:middlewares].push(Excon::HyperMedia::Middleware)

api = Excon.get('http://www.example.com/api.json')
api.class # => Excon::Response
```

Using the `HyperMedia` middleware, the `Excon::Response` object now knows how
to handle the HyperMedia aspect of the API:

```ruby
product = api.product(expand: { uid: 'hello' })
product.class # => Excon::Connection

response = product.get
response.class # => Excon::Response
response.body.class # => String
```

As seen above, you can expand URI Template variables using the `expand` option,
provided by the [`excon-addressable` library][excon-addressable].

Since each new resource is simply an `Excon::Response` object, accessed through
the default `Excon::Connection` object, all [Excon-provided options][options]
are available as well:

```ruby
product.get(idempotent: true, retry_limit: 6)
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## TODO

* make it easy to access attributes in response objects
* properly handle curied-links and/or non-valid Ruby method name links

[excon]: https://github.com/excon/excon
[hypermedia]: https://en.wikipedia.org/wiki/HATEOAS
[excon-addressable]: https://github.com/JeanMertz/excon-addressable
[options]: https://github.com/excon/excon#options
