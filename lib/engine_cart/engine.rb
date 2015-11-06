module EngineCart
  class Engine < Rails::Engine
    rake_tasks do
      load 'engine_cart/tasks/engine_cart.rake'
    end
  end
end
