# Routing Filter

[![Build Status](https://secure.travis-ci.org/svenfuchs/routing-filter.png)](http://travis-ci.org/svenfuchs/routing-filter)

Routing filters wrap around the complex beast that the Rails routing system is
to allow for unseen flexibility and power in Rails URL recognition and
generation.

As powerful and awesome the Rails' routes are, when you need to design your
URLs in a manner that only slightly leaves the paved cowpaths of Rails
conventions, you're usually unable to use all the goodness of helpers and
convenience that Rails ships with.

This library comes with four more or less reusable filters and it is easy to
implement custom ones. Maybe the most popular one is the Locale routing filter:

* `Locale` - prepends the page's :locale (e.g. /de/products)
* `Pagination` - appends page/:num (e.g. /products/page/2)
* `Uuid` - prepends a uuid for authentication or other purposes (e.g. /d00fbbd1-82b6-4c1a-a57d-098d529d6854/products/1)
* `Extension` - appends an extension (e.g. /products.html)


## Requirements

Latest routing-filter (~> 0.6.0) currently only works with Rails >= 4.2. It should
not be all too hard to get it working with plain Rack::Mount but I haven't had that
usecase, yet.

For older Rails use `0-4-stable` branch.

## Installation

Just install the Gem:

    $ gem install routing-filter

The Gem should work out of the box with Rails 4.2 after specifying it in your
application's Gemfile.

```ruby
# Gemfile
gem 'routing-filter'
```

## Usage

Once the Gem has loaded you can setup the filters in your routes file like this:

```ruby
# in config/routes.rb
Rails.application.routes.draw do
  filter :pagination, :uuid
end
```

Filters can also accept options:

```ruby
Rails.application.routes.draw do
  filter :extension, :exclude => %r(^admin/)
  filter :locale,    :exclude => /^\/admin/
end
```

The locale filter may be configured to not include the default locale:

    # in config/initializers/routing_filter.rb
    # Do not include default locale in generated URLs
    RoutingFilter::Locale.include_default_locale = false
    
    # Then if the default locale is :de
    # products_path(:locale => 'de') => /products
    # products_path(:locale => 'en') => /en/products

### Testing

RoutingFilter should not be enabled in functional tests by default since the Rails router gets
bypassed for most testcases. Having RoutingFilter enabled in this setup can cause missing parameters
in the test environment. Routing tests can/should re-enable RoutingFilter since the whole routing stack
gets executed for these testcases.

To disable RoutingFilter in your test suite add the following to your test_helper.rb / spec_helper.rb:

```ruby
RoutingFilter.active = false
```

## Running the tests

    $ bundle install
    $ bundle exec rake test

## Filter order

You can picture the way routing-filter wraps filters around your application as a russian puppet pattern. Your application sits in the center and is wrapped by a number of filters. An incoming request's path will be past through these layers of filters from the outside in until it is passed to the regular application routes set. When you generate URLs on the other hand then the filters will be run from the inside out.

Filter order might be confusing at first. The reason for that is that the way rack/mount (which is used by Rails as a core routing engine) is confusing in this respect and Rails tries to make the best of it.

Suppose you have a filter :custom in your application routes.rb file and an engine that adds a :common filter. Then Rails makes it so that your application's routes file will be loaded first (basically route.rb files are loaded in reverse engine load order).

Thus routing-filter will make your :custom filter the *inner-most* filter, wrapping the application *first*. The :common filter from your engine will be wrapped *around* that onion and will be made the *outer-most* filter.

This way common base filters (such as the locale filter) can run first and do not need to know about the specifics of other (more specialized, custom) filters. Custom filters on the other hand can easily take into account that common filters might already have run and adjust accordingly.


## Implementing your own filters

For example implementations have a look at the existing filters in
[lib/routing_filter/filters](http://github.com/svenfuchs/routing-filter/tree/master/lib/routing_filter/filters)

The following would be a sceleton of an empty filter:

```ruby
module RoutingFilter
  class Awesomeness < Filter
    def around_recognize(path, env, &block)
      # Alter the path here before it gets recognized.
      # Make sure to yield (calls the next around filter if present and
      # eventually `recognize_path` on the routeset):
      yield.tap do |params|
        # You can additionally modify the params here before they get passed
        # to the controller.
      end
    end

    def around_generate(params, &block)
      # Alter arguments here before they are passed to `url_for`.
      # Make sure to yield (calls the next around filter if present and
      # eventually `url_for` on the controller):
      yield.tap do |result|
        # You can change the generated url_or_path here. Make sure to use
        # one of the "in-place" modifying String methods though (like sub!
        # and friends).
      end
    end
  end
end
```

You can specify the filter explicitely in your routes.rb:

```ruby
Rails.application.routes.draw do
  filter :awesomeness
end
```

(I am not sure if it makes sense to provide more technical information than
this because the usage of this plugin definitely requires some advanced
knowledge about Rails internals and especially its routing system. So, I
figure, anyone who could use this should also be able to read the code and
figure out what it's doing much better then from any lengthy documentation.

If I'm mistaken on this please drop me an email with your suggestions.)


## Rationale: Two example usecases

### Conditionally prepending the locale

An early usecase from which this originated was the need to define a locale
at the beginning of an URL in a way so that

* the locale can be omitted when it is the default locale
* all the url\_helpers that are generated by named routes as well as url_for continue to work in
a concise manner (i.e. without specifying all parameters again and again)
* ideally also plays nicely with default route helpers in tests/specs

You can read about this struggle and two possible, yet unsatisfying solutions
[here](http://www.artweb-design.de/2007/5/13/concise-localized-rails-url-helpers-solved-twice).
The conclusion so far is that Rails itself does not provide the tools to solve
this problem in a clean and dry way.

### Expanding /sections/:id to nested tree segments

Another usecase that eventually spawned the implementation of this plugin was
the need to map an arbitrary count of path segments to a certain model
instance. In an application that I've been working on recently I needed to
map URL paths to a nested tree of models like so:

    root
    + docs
      + api
      + wiki

E.g. the docs section should map to the path `/docs`, the api section to
the path `/docs/api` and so on. Furthermore, after these paths there need to be
more things to be specified. E.g. the wiki needs to define a whole Rails
resource with URLs like `/docs/wiki/pages/1/edit`.

The only way to solve this problem with Rails' routing toolkit is to map
a big, bold `/*everything` catch-all ("globbing") route and process the whole
path in a custom dispatcher.

This, of course, is a really unsatisfying solution because one has to
reimplement everything that Rails routes are here to help with: regarding both
URL recognition (like parameter mappings, resources, ...) and generation
(url\_helpers).

## Solution

This plugin offers a solution that takes exactly the opposite route.

Instead of trying to change things *between* the URL recognition and
generation stages to achieve the desired result it *wraps around* the whole
routing system and allows to pre- and post-filter both what goes into it
(URL recognition) and what comes out of it (URL generation).

This way we can leave *everything* else completely untouched.

* We can tinker with the URLs that we receive from the server and feed URLs to
Rails that perfectly match the best breed of Rails' conventions.
* Inside of the application we can use all the nice helper goodness and
conveniences that rely on these conventions being followed.
* Finally we can accept URLs that have been generated by the url\_helpers and,
again, mutate them in the way that matches our requirements.

So, even though the plugin itself is a blatant monkey-patch to one of the
most complex area of Rails internals, this solution seems to be effectively
less intrusive and pricey than others are.

## Etc

Authors: [Sven Fuchs](http://www.artweb-design.de) <svenfuchs at artweb-design dot de>
License: MIT
