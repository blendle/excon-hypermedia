# Excon::Hypermedia [![wercker status](https://app.wercker.com/status/f3fd6cf2045566072ef26354d5a73e9f/s/master "wercker status")](https://app.wercker.com/project/bykey/f3fd6cf2045566072ef26354d5a73e9f)

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

## Quick Start

```ruby
Excon.defaults[:middlewares].push(Excon::HyperMedia::Middleware)

api = Excon.get('https://www.example.org/api.json')
api.class # => Excon::Response

product = api.rel('product', expand: { uid: 'bicycle' })
product.class # => Excon::Connection

response = product.get
response.class # => Excon::Response
response.resource.name # => 'bicycle'
```

## Usage

To let Excon know the API supports HyperMedia, simply enable the correct
middleware (either globally, or per-connection):

```ruby
Excon.defaults[:middlewares].push(Excon::HyperMedia::Middleware)

api = Excon.get('https://www.example.org/api.json')
api.class # => Excon::Response
```

> NOTE: we'll use the following JSON response body in the below examples:
> 
> **https://www.example.org/api.json**
> 
> ```json
> {
>   "_links": {
>     "self": {
>       "href": "https://www.example.org/api.json"
>     },
>     "product": {
>       "href": "https://www.example.org/product/{uid}",
>       "templated": true
>     }
>   }
> }
> ```
> 
> **https://www.example.org/product/bicycle**
> 
> ```json
> {
>   "_links": {
>     "self": {
>       "href": "https://www.example.org/product/bicycle"
>     }
>   },
>   "bike-type": "Mountain Bike",
>   "BMX": false,
>   "derailleurs": {
>     "back": 7,
>     "front": 3
>   },
>   "name": "bicycle",
>   "reflectors": true,
>   "_embedded": {
>     "pump": {
>       "_links": {
>         "self": "https://www.example.org/product/pump"
>       },
>       "weight": "2kg",
>       "type": "Floor Pump",
>       "valve-type": "Presta"
>     }
>   }
> }

With this middleware injected in the stack, Excon's model is now expanded with
several key concepts:

### resources

A **resource** is the representation of the object returned by the API. Almost
all other concepts and methods originate from this object.

Use the newly available `Excon::Response#resource` method to access the resource
object:

```ruby
api.resource.class # => Excon::HyperMedia::ResourceObject
```

A resource has several methods exposed:

```ruby
api.resource.public_methods(false) # => [:_links, :_properties, :_embedded]
```

Each of these methods represents one of the following HyperMedia concepts.

### links

A resource has links, that point to related resources (and itself), these can be
accessed as well:

```ruby
api.resource._links.class # => Excon::HyperMedia::ResourceObject::Links
```

You can get a list of valid links using `keys`:

```ruby
api.resource._links.keys # => ['self', 'product']
```

Each links is represented by a `LinkObject` instance:

```ruby
api.resource._links.product.class # => Excon::HyperMedia::LinkObject
api.resource._links.product.href # => 'https://www.example.org/product/{uid}'
api.resource._links.product.templated # => true
```

### relations

Links are the primary way to traverse between relations. This is what makes a
HyperMedia-based API "self-discoverable".

To go from one resource, to the next, you use the `rel` (short for relation)
method. This method is available on the `Excon::Response` instance.

Using `rel`, returns an `Excon::Connection` object, the same as if you where to
call `Excon.new`:

```ruby
rel = api.rel('self')
rel.class # => Excon::Connection
```

Since the returned object is of type `Excon::Connection`, all
[Excon-provided options][options] are available as well:

```ruby
rel.get(idempotent: true, retry_limit: 6)
```

Once you call `get` (or `post`, or any other valid Excon request method), you
are back where you started, with a new `Excon::Response` object, imbued with
HyperMedia powers:

```ruby
api.resource._links.keys # => ['self', 'product']
```

In this case, we ended up back with the same type of object as before. To go
anywhere meaningful, we want to use the `product` rel:

```ruby
product = api.rel('product', expand: { uid: 'bicycle' }).get
```

As seen above, you can expand URI Template variables using the `expand` option,
provided by the [`excon-addressable` library][excon-addressable].

### properties

Properties are what make a resource unique, they tell us more about the state of
the resource, they are the key/value pairs that define the resource.

In HAL/JSON terms, this is everything returned by the response body, excluding
the `_links` and `_embedded` sections:

```ruby
product.resource.name # => "bicycle"
product.resource.reflectors # => true
```

Nested properties are supported as well:

```ruby
product.resource.derailleurs.class # => Excon::HyperMedia::ResourceObject::Properties
product.resource.derailleurs.front # => 3
product.resource.derailleurs.back # => 7
```

Property names that aren't valid method names can always be accessed using the
hash notation:

```ruby
product.resource['bike-type'] # => 'Mountain Bike'
product.resource['BMX'] # => false
product.resource.bmx # => false
```

Properties should be implicitly accessed on a resource, but are internally
accessed via the `_properties` method:

```ruby
product.resource._properties.class # => Excon::HyperMedia::ResourceObject::Properties
```

The `Properties` object inherits its logics from `Enumerable`:

```ruby
product.resource._properties.to_h.class # => Hash
product.resource._properties.first # => ['name', 'bicycle']
```

### embedded

Embedded resources are resources that are available through link relations, but
embedded in the current resource for easier access.

For more information on this concept, see the [formal specification][_embedded].

Embedded resources work the same as the top-level resource:

```ruby
product._embedded.pump.class # => Excon::HyperMedia::ResourceObject
product._embedded.pump.weight # => '2kg'
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[excon]: https://github.com/excon/excon
[hypermedia]: https://en.wikipedia.org/wiki/HATEOAS
[excon-addressable]: https://github.com/JeanMertz/excon-addressable
[options]: https://github.com/excon/excon#options
[_embedded]: https://tools.ietf.org/html/draft-kelly-json-hal-08#section-4.1.2
