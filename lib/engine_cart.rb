require "engine_cart/version"

module EngineCart
  # Your code goes here...
  def self.load_application! path = nil
    require File.expand_path("config/environment", path || ENV['RAILS_ROOT'] || "./spec/internal")
  end
end
