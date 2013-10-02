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

Add this to your Rakefile:

    # Path to the test app
    # TEST_APP = 'spec/internal'
    # Path to files to include in the test app
    # TEST_APP_TEMPLATES = 'spec/test_app_templates'
    require 'engine_cart/rake_task'

In your rake tasks, you can require the test app get build first:

    task :ci => ['engine_cart:generate'] do
      # run the tests
    end


And in your e.g. spec_helper:

  require 'engine_cart'
  EngineCart.load_application!


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
