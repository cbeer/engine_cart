# EngineCart

TODO: Write a gem description

## Installation

Add this line to your engines's Gemfile:

    gem 'engine_cart'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install engine_cart


## Usage

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

You can configure where the test app is created by setting the `TEST_APP` constant, e.g.:

```ruby
  TEST_APP = "/tmp/generate-the-test-app-into-tmp-instead-of-your-app
```

You can also inject additional gems, or run other Rails generators by adding files to the `TEST_APP_TEMPLATES` directory.

Gemfile.extra

test_app generator

within_test_app

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
