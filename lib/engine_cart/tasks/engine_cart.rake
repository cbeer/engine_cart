require 'engine_cart'
require 'yaml'

namespace :engine_cart do

  desc "Prepare a gem for using engine_cart"
  task :prepare do
    require 'generators/engine_cart/install_generator'
    generator = EngineCart::InstallGenerator.new
    generator.create_test_app_templates
    generator.ignore_test_app
    generator.add_gemfile_include
  end

  task :setup do
  end

  desc "Clean out the test rails app"
  task :clean => [:setup] do
    puts "Removing sample rails app"
    `rm -rf #{EngineCart.destination}`
  end

  task :create_test_rails_app => [:setup] do
    require 'tmpdir'
    require 'fileutils'
    Dir.mktmpdir do |dir|
      Dir.chdir dir do
        version = if Gem.loaded_specs["rails"]
          "_#{Gem.loaded_specs["rails"].version}_"
        end

        Bundler.with_clean_env do
          `rails #{version} new internal --skip-spring #{EngineCart.rails_options} #{"-m #{EngineCart.template}" if EngineCart.template}`
        end

        unless $?
          raise "Error generating new rails app. Aborting."
        end
      end

      FileUtils.move "#{dir}/internal", "#{EngineCart.destination}"

    end
  end

  task :inject_gemfile_extras => [:setup] do
    # Add our gem and extras to the generated Rails app
    open(File.expand_path('Gemfile', EngineCart.destination), 'a') do |f|
      gemfile_extras_path = File.expand_path("Gemfile.extra", EngineCart.templates_path)

      f.write <<-EOF
        gem '#{EngineCart.current_engine_name}', :path => '#{File.expand_path('.')}'
EOF
    end
  end

  desc "Create the test rails app"
  task :generate => [:setup] do
    unless File.exists? File.expand_path('.generated_engine_cart', EngineCart.destination)

      # Create a new test rails app
      Rake::Task['engine_cart:create_test_rails_app'].invoke

      system "bundle install"

      Rake::Task['engine_cart:inject_gemfile_extras'].invoke

      # Copy our test app generators into the app and prepare it
      if File.exists? "#{EngineCart.templates_path}/lib/generators"
        system "cp -r #{EngineCart.templates_path}/lib/generators #{EngineCart.destination}/lib"
      end

      within_test_app do
        system "bundle install"
        system "(rails g | grep test_app) && rails generate test_app"
        system "rake db:migrate db:test:prepare"
      end

      File.open(File.expand_path('.generated_engine_cart', EngineCart.destination), 'w') { |f| f.puts env_context_hash.to_yaml }

      puts "Done generating test app"
    end
  end
end

def within_test_app
  Dir.chdir(EngineCart.destination) do
    Bundler.with_clean_env do
      yield
    end
  end
end

# A hash of pertinent details of the current ruby/rails environment. 
def env_context_hash
  # RUBY_DESCRIPTION constant is same as output of 'ruby -v'
  hash = {}
  hash["RUBY_DESCRIPTION"] = RUBY_DESCRIPTION 
  hash["BUNDLE_GEMFILE"] = ENV["BUNDLE_GEMFILE"] if ENV["BUNDLE_GEMFILE"]
  
  # Current Rails version, if none can be found, don't include
  begin
    hash["RAILS_VERSION"] = Gem::Specification.find_by_name("rails").version.to_s 
  rescue Gem::LoadError
  end

  return hash
end
