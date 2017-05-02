module EngineCart
  def self.gemfile_stanza_check_line
    "engine_cart stanza: 0.10.0"
  end

  def self.gemfile_stanza_text
    <<-EOF.gsub(/^    /, '')
    # BEGIN ENGINE_CART BLOCK
    # engine_cart: #{EngineCart::VERSION}
    # #{EngineCart.gemfile_stanza_check_line}
    # the below comes from engine_cart, a gem used to test this Rails engine gem in the context of a Rails app.
    file = File.expand_path('Gemfile', ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path('#{EngineCart.destination}', File.dirname(__FILE__)))
    if File.exist?(file)
      begin
        eval_gemfile file
      rescue Bundler::GemfileError => e
        Bundler.ui.warn '[EngineCart] Skipping Rails application dependencies:'
        Bundler.ui.warn e.message
      end
    else
      Bundler.ui.warn "[EngineCart] Unable to find test application dependencies in \#{file}, using placeholder dependencies"

      if ENV['RAILS_VERSION']
        if ENV['RAILS_VERSION'] == 'edge'
          gem 'rails', github: 'rails/rails'
          ENV['ENGINE_CART_RAILS_OPTIONS'] = '--edge --skip-turbolinks'
        else
          gem 'rails', ENV['RAILS_VERSION']
        end
      end

      case ENV['RAILS_VERSION']
      when /^4\.2/
        gem 'responders', '~> 2.0'
        gem 'sass-rails', '>= 5.0'
        gem 'coffee-rails', '~> 4.1.0'
      when /^4\.[01]/
        gem 'sass-rails', '< 5.0'
        # Required by https://github.com/rails/rails/blob/v4.1.14/railties/lib/rails/generators/app_base.rb#L257
        gem 'sass-rails', "~> 4.0.3"
      end
    end
    # END ENGINE_CART BLOCK
    EOF
  end
end
