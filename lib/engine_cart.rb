require "engine_cart/version"

module EngineCart
  require "engine_cart/engine" if defined? Rails

  class << self

    ##
    # Name of the engine we're testing
    attr_accessor :engine_name

    ##
    # Destination to generate the test app into
    attr_accessor :destination

    ##
    # Path to a Rails application template
    attr_accessor :template

    ##
    # Path to test app templates to make available to
    # the test app generator
    attr_accessor :templates_path

  end

  self.engine_name = ENV["CURRENT_ENGINE_NAME"]
  self.destination = ENV['ENGINE_CART_DESTINATION'] || "./spec/internal"
  self.template = ENV["ENGINE_CART_TEMPLATE"] || (File.expand_path('template.rb') if File.exists? 'template.rb')
  self.templates_path = ENV['ENGINE_CART_TEMPLATES_PATH'] || "./spec/test_app_templates"

  def self.current_engine_name
    engine_name || File.basename(Dir.glob("*.gemspec").first, '.gemspec')
  end

  def self.load_application! path = nil
    require File.expand_path("config/environment", path || ENV['RAILS_ROOT'] || EngineCart.destination)
  end

  def self.within_test_app
    Dir.chdir(EngineCart.destination) do
      Bundler.with_clean_env do
        yield
      end
    end
  end
end
