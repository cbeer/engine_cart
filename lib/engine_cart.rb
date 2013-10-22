require "engine_cart/version"
module EngineCart
  require "engine_cart/engine"
  
  def self.load_application! path = nil
    require File.expand_path("config/environment", path || ENV['RAILS_ROOT'] || "./spec/internal")
  end
end
