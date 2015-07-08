require 'rails/generators'

##
# EngineCartGenerator sets up an engine to
# use engine_cart-generated test apps
module EngineCart
  class InstallGenerator < Rails::Generators::Base
    def create_test_app_templates
      empty_directory EngineCart.templates_path

      empty_directory File.expand_path("lib/generators", EngineCart.templates_path)

      create_file File.expand_path("lib/generators/test_app_generator.rb", EngineCart.templates_path), :skip => true do
        <<-EOF
        require 'rails/generators'

        class TestAppGenerator < Rails::Generators::Base
          source_root "#{EngineCart.templates_path}"

          # if you need to generate any additional configuration
          # into the test app, this generator will be run immediately
          # after setting up the application

          def install_engine
            generate '#{EngineCart.current_engine_name}:install'
          end
        end

        EOF
      end
    end

    def ignore_test_app
      # Ignore the generated test app in the gem's .gitignore file
      git_root = (`git rev-parse --show-toplevel` rescue '.').strip

      # If we don't have a .gitignore file already, don't worry about it
      return unless File.exists? File.expand_path('.gitignore', git_root)

      # If the directory is already ignored (somehow) don't worry about it
      return if (system('git', 'check-ignore', TEST_APP, '-q') rescue false)

      append_file  File.expand_path('.gitignore', git_root) do
        "\n#{EngineCart.destination}\n"
      end
    end

    def add_gemfile_include
      append_file "Gemfile" do
        <<-EOF

  # the below comes from engine_cart, a gem used to test this Rails engine gem in the context of a Rails app
  file = File.expand_path("Gemfile", ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path("../spec/internal", __FILE__))
  if File.exist?(file)
    puts "Loading \#{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
    instance_eval File.read(file)
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
        EOF
      end
    end
  end
end
