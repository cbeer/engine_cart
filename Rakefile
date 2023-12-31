require "bundler/gem_tasks"
require 'engine_cart/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :ci => ['generate_test_gem', 'spec'] do

end

task :generate_test_gem => ['engine_cart:setup'] do
  system("rm -rf .internal_test_gem")
  gem 'rails', ENV['RAILS_VERSION']

  rails_path = Gem.bin_path('railties', 'rails')
  puts rails_path

  require "rails/generators"
  require "rails/generators/rails/plugin/plugin_generator"

  pwd = Dir.pwd
  Rails::Generators::PluginGenerator.start ['internal_test_gem']

  Dir.chdir(pwd)

  system("mv #{Dir.pwd}/internal_test_gem #{Dir.pwd}/.internal_test_gem")

  gemspec_data = File.open(".internal_test_gem/internal_test_gem.gemspec") do |f|
    f.read.gsub(/FIXME/, "DONTCARE")
          .gsub(/TODO/, "DONTCARE")
          .gsub(/.*homepage.*/, "")
          .gsub(/.*sqlite3.*/, "")
          .gsub(/.*source_code_uri.*/, "")
          .gsub(/.*changelog_uri.*/, "")
  end

  IO.write(".internal_test_gem/internal_test_gem.gemspec", gemspec_data)
  IO.write(".internal_test_gem/Gemfile", File.open(".internal_test_gem/Gemfile") {|f| f.read.gsub(/.*sqlite3.*/, "")})

  Rake::Task['engine_cart:inject_gemfile_extras'].invoke
  EngineCart.within_test_app do
    system "git init"
    FileUtils.touch('.gitignore')
    Dir.mkdir('spec')
    File.open('spec/spec_helper.rb', 'w') do |f|
      f.puts <<-EOF
        require 'engine_cart'
        EngineCart.load_application!

        require 'rspec/rails'

        require 'internal_test_gem'
        RSpec.configure do |config|

        end
      EOF
    end

    system "echo '\ngem \"rspec-rails\"\n' >> Gemfile"
    if RUBY_VERSION < '3.0'
      system "echo '\ngem \"sqlite3\", \"< 1.7.0\"\n' >> Gemfile"
    end

    Bundler.unbundled_system "bundle update --quiet"
    system "echo 'require \"engine_cart/rake_task\"\n' >> Rakefile"

    system("bundle exec rake engine_cart:prepare")
    Bundler.unbundled_system "bundle install --quiet"
  end
end

task :default => :ci
