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

      Rake::Task['engine_cart:clean'].invoke if File.exist? EngineCart.destination
      FileUtils.move "#{dir}/internal", "#{EngineCart.destination}"

      if Gem.loaded_specs["rails"].version.to_s < '4.2.4'
        has_web_console = false

        # Hack for https://github.com/rails/web-console/issues/150
        IO.write("spec/internal/Gemfile", File.open("spec/internal/Gemfile") do |f|
          text = f.read
          has_web_console = text.match('web-console')
          text.gsub(/.*web-console.*/, "").gsub(/.*IRB console on exception pages.*/, "")
        end)

        File.open("spec/internal/Gemfile", "a") do |f|
          f.puts 'gem "web-console", group: :development'
        end if has_web_console
      end
    end
  end

  task :inject_gemfile_extras => [:setup] do
    # Add our gem and extras to the generated Rails app
    open(File.expand_path('Gemfile', EngineCart.destination), 'a') do |f|
      gemfile_extras_path = File.expand_path("Gemfile.extra", EngineCart.templates_path)

      f.write <<-EOF
        #{File.read(gemfile_extras_path) if File.exist?(gemfile_extras_path)}
        gem '#{EngineCart.current_engine_name}', :path => '#{File.expand_path('.')}'
EOF
    end
  end

  desc "Create the test rails app"
  task :generate, [:fingerprint] => [:setup] do |t, args|
    original_fingerprint = args[:fingerprint]
    args.with_defaults(:fingerprint => EngineCart.fingerprint) unless original_fingerprint

    f = File.expand_path('.generated_engine_cart', EngineCart.destination)
    unless File.exist?(f) && File.read(f) == args[:fingerprint]

      # Create a new test rails app
      Rake::Task['engine_cart:create_test_rails_app'].invoke

      system "bundle install"

      Rake::Task['engine_cart:inject_gemfile_extras'].invoke

      # Copy our test app generators into the app and prepare it
      if File.exist? "#{EngineCart.templates_path}/lib/generators"
        system "cp -r #{EngineCart.templates_path}/lib/generators #{EngineCart.destination}/lib"
      end

      within_test_app do
        system "bundle install"
        system "(rails g | grep test_app) && rails generate test_app"
        system "rake db:migrate db:test:prepare"
      end

      system "bundle install"

      File.open(File.expand_path('.generated_engine_cart', EngineCart.destination), 'w') { |f| f.write(original_fingerprint || EngineCart.fingerprint) }

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
