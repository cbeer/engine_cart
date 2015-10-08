[![Build Status](https://travis-ci.org/cbeer/engine_cart.svg?branch=master)](https://travis-ci.org/cbeer/engine_cart) [![Gem Version](https://badge.fury.io/rb/engine_cart.svg)](http://badge.fury.io/rb/engine_cart)

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

### engine_cart rake tasks

To use engine_cart's rake tasks, in *your* engine's Rakefile add:

```ruby
require 'engine_cart/rake_task'
```

### Set up your engine to use engine_cart

#### run engine_cart:prepare

In order for your Rails engine gem to use engine_cart, some configuration is required. There is an EngineCart generator to do this. It is also packaged as a rake task.

```
$ rake engine_cart:prepare
```

This will create lib/generators/test_app_generator.rb in your engine and it will also append some code to your engine's Gemfile.

You only need to run this rake task once.

#### adjust your engine's generators

engine_cart is configured so it will run the test app generator (located in ./spec/test_app_templates/lib/generators) immediately after generating a testing rails app. By default, it will attempt to run the `install` generator for your engine. If you do not have an `install` generator, or want to add additional steps (e.g. to install additional gems), you can add them to the `TestAppGenerator`.


### Generate the testing Rails application

You can generate a Rails testing application for your engine with a rake task:

```
$ rake engine_cart:generate
```

This creates a new Rails app containing your engine at ./spec/internal by running generators.

You can start the testing app, interact with it, etc:

```
$ cd spec/internal
$ rails s
```

The testing app starts at [[http://localhost:3000|http://localhost:3000]], just like any Rails app.

from the spec/internal directory, you can do normal Rails things, like:
* run rake tasks
* run rails console

### Clean out testing application

To clean out the testing app: (from top level directory, not from spec/internal)

```
$ rake engine_cart:clean
```

Or, if you wish to start over with a pristine testing application:

```
$ rake engine_cart:regenerate
```

Sometimes, particularly when Bundler gets confused and rake won't work, you need to clean out the test application manually:

```
$ rm -r spec/internal
```

(See also Gotcha below)

### Running Tests using the Rails application

The easiest way to do this is via a rake task.  In your engine's Rakefile:

```ruby
require 'engine_cart/rake_task'

task :ci => ['engine_cart:generate'] do
  # run the tests
end
```

And in your engine's test framework configuration (e.g. spec\_helper.rb or rails\_helper.rb), initialize EngineCart:

```ruby
  require 'engine_cart'
  EngineCart.load_application!
```

Your test files (e.g. spec files for your engine) can now be written as tests for a Rails application.

## Gotcha

If you have generated a test application, there is a Gemfile and Gemfile.lock associated with the testing app at spec/internal (or wherever you designated as the test app location).  If you then update *your* engine's Gemfile or gemspec, Bundler can get confused if it has conflicting information between your engine and the testing app.

To fix this:

1. clean out your testing app `$ rm spec/internal`  # rake may not be avail.
2. remove your engine's Gemfile.lock `$ rm Gemfile.lock`  # not always necess.
3. allow Bundler to resolve gem dependencies again `$ bundle install`


## Configuration

### location of Rails testing app

You can configure where the test app is created by setting the `ENGINE_CART_DESTINATION` env variable, e.g.:

```
ENGINE_CART_DESTINATION="/tmp/my_engines_test_app_here" rake engine_cart:generate
```

### adjusting generators for Rails testing app

After creating the test application, EngineCart will run the test app generator (located in ./spec/test_app_templates/lib/generators). By default, it will attempt to run the `install` generator for your engine. If you do not have an `install` generator, or want to add additional steps (e.g. to install additional gems), you can add them to the `TestAppGenerator`.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Make sure to add tests for your changes.
5. Make sure all engine_cart tests pass.
6. Push to the branch (`git push origin my-new-feature`)
7. Create a [Pull Request](https://help.github.com/articles/using-pull-requests/)
