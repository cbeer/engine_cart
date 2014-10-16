# EngineCart

Rake tasks to generate a test application for a Rails Engine gem.

If you have a Rails Engine and want to test it, the suggested approach is a small dummy application that loads up a Rails application with your engine loaded. This dummy application is usually checked into source control and maintained with the application. This works great, until you want to test:

 - different versions of Ruby (e.g. MRI and JRuby)
 - different versions of Rails (Rails 3.x, 4.0 and 4.1)
 - different deployment environments (with and without devise, etc)

where each scenario may involve different configurations, Gemfiles, etc. 

EngineCart helps by adding Rake tasks to your Engine that builds a test application for you using Rails generators (and/or application templates). 


## Installation

Add this line to your engines's Gemfile:

    gem 'engine_cart'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install engine_cart

## Usage

Engine Cart comes with a generator to set up your engine to use Engine Cart. It is also packaged as a rake task:

In your Rakefile add:

```ruby
require 'engine_cart/rake_task'
```

then you can call: 

```
$ rake engine_cart:prepare
```

In your Rakefile you can generate the Rails application using, e.g.:

```ruby
require 'engine_cart/rake_task'

task :ci => ['engine_cart:generate'] do
  # run the tests
end
```

And in your e.g. spec_helper.rb, initialize EngineCart:

```ruby
  EngineCart.load_application!
```

## Configuration

You can configure where the test app is created by setting the `ENGINE_CART_DESTINATION` env variable, e.g.:

```ruby
ENGINE_CART_DESTINATION="/tmp/generate-the-test-app-into-tmp-instead-of-your-app" rake ci
```

After creating the test application, Engine Cart will run the test app generator (located in ./spec/test_app_templates/lib/generators). By default, it will attempt to run the `install` generator for your engine. If you do not have an `install` generator, or want to add additional steps (e.g. to install additional gems), you can add them to the `TestAppGenerator`.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
