require 'engine_cart'

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
    EngineCart.check_for_gemfile_stanza
  end

  desc 'Regenerate the test rails app'
  task :regenerate => [:clean, :generate]

  desc "Clean out the test rails app"
  task :clean => [:setup] do
    puts "Removing sample rails app"
    `rm -rf #{EngineCart.destination}`
  end

  task :create_test_rails_app => [:setup] do
    require 'tmpdir'
    require 'fileutils'
    Dir.mktmpdir do |dir|
      # Fork into a new process to avoid polluting the current one with the partial Rails environment ...
      pid = fork do
        Dir.chdir dir do
          require 'rails/generators'
          require 'rails/generators/rails/app/app_generator'

          # Using the Rails generator directly, instead of shelling out, to
          # ensure we use the right version of Rails.
          Rails::Generators::AppGenerator.start([
            'internal',
            '--skip-git',
            '--skip-keeps',
            '--skip_spring',
            '--skip-bootsnap',
            '--skip-listen',
            '--skip-test',
            *EngineCart.rails_options,
            ("-m #{EngineCart.template}" if EngineCart.template)
          ].compact)
        end
        exit 0
      end

      # ... and then wait for it to catch up.
      _, status = Process.waitpid2 pid
      exit status.exitstatus unless status.success?

      Rake::Task['engine_cart:clean'].invoke if File.exist? EngineCart.destination
      FileUtils.move "#{dir}/internal", "#{EngineCart.destination}"

      if Gem.loaded_specs['rails'].version.to_s < '5.2.3'
        # Hack for https://github.com/rails/rails/issues/35153
        gemfile = File.join(EngineCart.destination, 'Gemfile')
        IO.write(gemfile, File.open(gemfile) do |f|
          text = f.read
          text.gsub(/^gem ["']sqlite3["']$/, 'gem "sqlite3", "~> 1.3.0"')
        end)
      end
    end
  end

  task :inject_gemfile_extras => [:setup] do
    # Add our gem and extras to the generated Rails app
    open(File.expand_path('Gemfile', EngineCart.destination), 'a') do |f|
      f.puts "gemspec path: '#{File.expand_path('.')}'"

      gemfile_extras_path = File.expand_path("Gemfile.extra", EngineCart.templates_path)
      f.puts "eval_gemfile File.expand_path('#{gemfile_extras_path}', File.dirname(__FILE__)) if File.exist?('#{gemfile_extras_path}')"
    end
  end

  desc 'find out if the generated app needs to be rebuilt'
  task :test => [:setup] do
    EngineCart.debug = true
    if EngineCart.fingerprint_expired?
      puts "Expired!"
      exit 1
    end
  end

  desc "Create the test rails app"
  task :generate => [:setup] do
    if EngineCart.fingerprint_expired?

      # Create a new test rails app
      Rake::Task['engine_cart:create_test_rails_app'].invoke

      Bundler.clean_system "bundle install --quiet"

      Rake::Task['engine_cart:inject_gemfile_extras'].invoke

      # Copy our test app generators into the app and prepare it
      if File.exist? "#{EngineCart.templates_path}/lib/generators"
        Bundler.clean_system "cp -r #{EngineCart.templates_path}/lib/generators #{EngineCart.destination}/lib"
      end

      within_test_app do
        unless (system("bundle install --quiet") or system("bundle update --quiet")) and
              system "(bundle exec rails g | grep test_app) && bundle exec rails generate test_app" and
              system "bundle exec rake db:migrate db:test:prepare"
          raise "EngineCart failed on with: #{$?}"
        end
      end

      Bundler.clean_system "bundle install --quiet"

      EngineCart.write_fingerprint

      puts "Done generating test app"
    end
  end

  desc 'Start the internal test application using `rails server`'
  task :server, [:rails_server_args] => [:generate] do |_, args|
    within_test_app do
      system "bundle exec rails server #{args[:rails_server_args]}"
    end
  end

  desc 'Start the internal test application using `rails console`'
  task :console, [:rails_console_args] => [:generate] do |_, args|
    within_test_app do
      system "bundle exec rails console #{args[:rails_console_args]}"
    end
  end
end

def within_test_app
  puts "\rtravis_fold:start:enginecart-bundler-cleanenv\r" if ENV['TRAVIS'] == 'true'
  Dir.chdir(EngineCart.destination) do
    Bundler.with_clean_env do
      yield
    end
  end
ensure
  puts "\rtravis_fold:end:enginecart-bundler-cleanenv\r" if ENV['TRAVIS'] == 'true'
end
