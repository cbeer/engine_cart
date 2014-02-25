namespace :engine_cart do

  desc "Prepare a gem for using engine_cart"
  task :prepare do
    require 'generators/engine_cart/engine_cart_generator'
    generator = EngineCartGenerator.new
    generator.create_test_app_templates
    generator.ignore_test_app
  end

  task :setup do
    TEST_APP_TEMPLATES = 'spec/test_app_templates' unless defined? TEST_APP_TEMPLATES
    TEST_APP = 'spec/internal' unless defined? TEST_APP
  end

  desc "Clean out the test rails app"
  task :clean => [:setup] do
    puts "Removing sample rails app"
    `rm -rf #{TEST_APP}`
  end

  task :create_test_rails_app => [:setup] do
    require 'fileutils'
    Dir.mktmpdir do |dir|
      Dir.chdir dir do
        version = if Gem.loaded_specs["rails"]
          "_#{Gem.loaded_specs["rails"].version}_"
        end

        Bundler.with_clean_env do
          `rails #{version} new internal`
        end
        unless $?
          raise "Error generating new rails app. Aborting."
        end
      end

      FileUtils.move "#{dir}/internal", "#{TEST_APP}"

    end
  end

  task :inject_gemfile_extras => [:setup] do
    # Add our gem and extras to the generated Rails app
    open(File.expand_path('Gemfile', TEST_APP), 'a') do |f|
      gemfile_extras_path = File.expand_path("Gemfile.extra", TEST_APP_TEMPLATES)

      f.write <<-EOF
        gem '#{current_engine_name}', :path => '#{File.expand_path('.')}'

        if File.exists?("#{gemfile_extras_path}")
          eval File.read("#{gemfile_extras_path}"), nil, "#{gemfile_extras_path}"
        end
EOF
    end
  end

  desc "Create the test rails app"
  task :generate => [:setup] do

    unless File.exists? File.expand_path('Rakefile', TEST_APP)
      # Create a new test rails app
      Rake::Task['engine_cart:create_test_rails_app'].invoke
      Rake::Task['engine_cart:inject_gemfile_extras'].invoke

      # Copy our test app generators into the app and prepare it
      system "cp -r #{TEST_APP_TEMPLATES}/lib/generators #{TEST_APP}/lib"
      within_test_app do
        system "bundle install"
        system "rails generate test_app"
        system "rake db:migrate db:test:prepare"
      end
      puts "Done generating test app"
    end
  end
end

def current_engine_name
  ENV["CURRENT_ENGINE_NAME"] || File.basename(Dir.glob("*.gemspec").first, '.gemspec')
end

def within_test_app
  Dir.chdir(TEST_APP) do
    Bundler.with_clean_env do
      yield
    end
  end
end
