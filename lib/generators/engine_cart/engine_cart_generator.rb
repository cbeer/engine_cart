require 'rails/generators'

class EngineCartGenerator < Rails::Generators::Base
  TEST_APP_TEMPLATES = 'spec/test_app_templates' unless defined? TEST_APP_TEMPLATES
  TEST_APP = 'spec/internal' unless defined? TEST_APP

  def create_test_app_templates
    empty_directory TEST_APP_TEMPLATES
    create_file File.expand_path("Gemfile.extra", TEST_APP_TEMPLATES), :skip => true do
      "# extra gems to load into the test app go here"
    end

    empty_directory File.expand_path("lib/generators", TEST_APP_TEMPLATES)

    create_file File.expand_path("lib/generators/test_app_generator.rb", TEST_APP_TEMPLATES), :skip => true do
      <<-EOF
      require 'rails/generators'

      class TestAppGenerator < Rails::Generators::Base
        source_root "#{TEST_APP_TEMPLATES}"

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
    return unless (system('git', 'check-ignore', TEST_APP, '-q') rescue false)
    
    inject_into_file File.expand_path('.gitignore', git_root), :before => "\Z" do 
      "#{TEST_APP}"
    end 
  end
end