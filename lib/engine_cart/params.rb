module EngineCart
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


    ##
    # Additional options when generating a test rails application
    attr_accessor :rails_options

  end

  self.engine_name = ENV["CURRENT_ENGINE_NAME"]

  def self.default_destination
    ('.internal_test_app' if File.exist? '.internal_test_app') || ('spec/internal' if File.exist? 'spec/internal') || '.internal_test_app'
  end

  self.destination = ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || default_destination
  self.template = ENV["ENGINE_CART_TEMPLATE"]
  self.templates_path = ENV['ENGINE_CART_TEMPLATES_PATH'] || "./spec/test_app_templates"
  self.rails_options = ENV['ENGINE_CART_RAILS_OPTIONS']
end