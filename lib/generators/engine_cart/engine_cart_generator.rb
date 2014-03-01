require 'rails/generators'

class EngineCartGenerator < Rails::Generators::Base
  def create_test_app_templates
    empty_directory EngineCart.templates_path
    create_file File.expand_path("Gemfile.extra", EngineCart.templates_path), :skip => true do
      "# extra gems to load into the test app go here"
    end

    empty_directory File.expand_path("lib/generators", EngineCart.templates_path)

    create_file File.expand_path("lib/generators/test_app_generator.rb", EngineCart.templates_path), :skip => true do
      <<-EOF
      require 'rails/generators'

      class TestAppGenerator < Rails::Generators::Base
        source_root "#{EngineCart.templates_path}"

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
      "#{EngineCart.destination}\n"
    end 
  end
end