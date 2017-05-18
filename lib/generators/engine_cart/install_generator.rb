require 'rails/generators'
require 'engine_cart/version'
require 'engine_cart/gemfile_stanza'

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
            generate '#{EngineCart.engine_name}:install'
          end
        end

        EOF
      end
    end

    def ignore_test_app(app_path = nil)
      app_path ||= EngineCart.destination

      # Ignore the generated test app in the gem's .gitignore file
      git_root = (`git rev-parse --show-toplevel` rescue '.').strip

      # If we don't have a .gitignore file already, don't worry about it
      return unless File.exist? File.expand_path('.gitignore', git_root)

      # If the directory is already ignored (somehow) don't worry about it
      return if (system('git', 'check-ignore', app_path, '-q') rescue false)

      append_file File.expand_path('.gitignore', git_root) do
        "\n#{app_path}\n"
      end
    end

    def add_gemfile_include
      append_file "Gemfile" do
        EngineCart.gemfile_stanza_text
      end
    end
  end
end
