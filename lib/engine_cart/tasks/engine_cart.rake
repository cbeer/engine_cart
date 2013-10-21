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
      system "rails new #{TEST_APP}"
      open(File.expand_path('Gemfile', TEST_APP), 'a') do |f|
        gemfile_extras_path = File.expand_path("Gemfile.extra", TEST_APP_TEMPLATES)

        f.write <<-EOF
        gem '#{current_engine_name}', :path => '../../'

        if File.exists?("#{gemfile_extras_path}")
          eval File.read("#{gemfile_extras_path}"), nil, "#{gemfile_extras_path}"
        end
EOF
      end

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