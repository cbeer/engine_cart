require "engine_cart/version"

module EngineCart
  require "engine_cart/engine" if defined? Rails

  class << self
    attr_accessor :templates_path
    attr_accessor :destination
    attr_accessor :engine_name
  end

  self.engine_name = ENV["CURRENT_ENGINE_NAME"]
  self.destination = ENV['ENGINE_CART_DESTINATION'] || "./spec/internal"
  self.templates_path = ENV['ENGINE_CART_TEMPLATES_PATH'] || "./spec/test_app_templates"

  def self.current_engine_name
    engine_name || File.basename(Dir.glob("*.gemspec").first, '.gemspec')
  end

  def self.load_application! path = nil
    require File.expand_path("config/environment", path || ENV['RAILS_ROOT'] || EngineCart.destination)
  end
end
