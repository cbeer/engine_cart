module EngineCart
  def self.gemfile_stanza_check_line
    "engine_cart stanza: 0.8.0"
  end

  def self.gemfile_stanza_text
    <<-EOF.gsub(/^    /, '')
    # BEGIN ENGINE_CART BLOCK
    # engine_cart: #{EngineCart::VERSION}
    # #{EngineCart.gemfile_stanza_check_line}
    # the below comes from engine_cart, a gem used to test this Rails engine gem in the context of a Rails app.
    file = File.expand_path("Gemfile", ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path("../spec/internal", __FILE__))
    if File.exist?(file)
      begin
        eval_gemfile file
      rescue Bundler::GemfileError => e
        Bundler.ui.warn '[EngineCart] Skipping Rails application dependencies:'
        Bundler.ui.warn e.message
      end
    else
      # we get here when we haven't yet generated the testing app via engine_cart
      gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']

      if ENV['RAILS_VERSION'] && ENV['RAILS_VERSION'] =~ /^4.2/
        gem 'responders', "~> 2.0"
        gem 'sass-rails', ">= 5.0"
      else
        gem 'sass-rails', "< 5.0"
      end
    end
    # END ENGINE_CART BLOCK
    EOF
  end
end