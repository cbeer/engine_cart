require 'rails/generators'

class EngineCartGenerator < Rails::Generators::Base
  TEST_APP_TEMPLATES = 'spec/test_app_templates' unless defined? TEST_APP_TEMPLATES
  TEST_APP = 'spec/internal' unless defined? TEST_APP

  def create_test_app_templates
    empty_directory TEST_APP_TEMPLATES
    create_file File.expand_path("Gemfile.extra", TEST_APP_TEMPLATES) do
      "# extra gems to load into the test app go here"
    end

    empty_directory File.expand_path("lib/generators", TEST_APP_TEMPLATES)

    create_file File.expand_path("lib/generators/test_app_generator.rb", TEST_APP_TEMPLATES) do
      <<-EOF
      require 'rails/generators'

      class TestAppGenerator < Rails::Generators::Base
        source_root #{TEST_APP_TEMPLATES}

      end

      EOF
    end
  end

  def ignore_test_app
      # Ignore the generated test app in the gem's .gitignore file
      # (if it exists, and the test app isn't already ignored)
      git_root = (`git rev-parse --show-toplevel` rescue '.').strip

      open(File.expand_path('.gitignore', git_root), 'a') do |f|
        f.write "#{TEST_APP}\n"
      end if File.exists?(File.expand_path('.gitignore', git_root)) and !(system('git', 'check-ignore', TEST_APP) rescue false)

  end
end