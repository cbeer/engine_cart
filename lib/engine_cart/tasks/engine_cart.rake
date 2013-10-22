namespace :engine_cart do

  task :setup do
    TEST_APP_TEMPLATES = 'spec/test_app_templates' unless defined? TEST_APP_TEMPLATES
    TEST_APP = 'spec/internal' unless defined? TEST_APP
  end

  desc "Clean out the test rails app"
  task :clean => [:setup] do
    puts "Removing sample rails app"
    `rm -rf #{TEST_APP}`
  end

  desc "Create the test rails app"
  task :generate => [:setup] do

    unless File.exists? File.expand_path('Rakefile', TEST_APP)
      # Create a new test rails app
      system "rails new #{TEST_APP}"

      # Ignore the generated test app in the gem's .gitignore file
      # (if it exists, and the test app isn't already ignored)
      git_root = (`git rev-parse --show-toplevel` rescue '.').strip

      open(File.expand_path('.gitignore', git_root), 'a') do |f|
        f.write <<-EOF
          #{TEST_APP}
        EOF
      end if File.exists?(File.expand_path('.gitignore', git_root)) and !(system('git', 'check-ignore', TEST_APP) rescue false)

      # Add our gem and extras to the generated Rails app
      open(File.expand_path('Gemfile', TEST_APP), 'a') do |f|
        gemfile_extras_path = File.expand_path("Gemfile.extra", TEST_APP_TEMPLATES)

        f.write <<-EOF
        gem '#{current_engine_name}', :path => '../../'

        if File.exists?("#{gemfile_extras_path}")
          eval File.read("#{gemfile_extras_path}"), nil, "#{gemfile_extras_path}"
        end
EOF
      end

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
  File.basename(Dir.glob("*.gemspec").first, '.gemspec')
end

def within_test_app
  Dir.chdir(TEST_APP) do
    Bundler.with_clean_env do
      yield
    end
  end
end