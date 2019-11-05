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
  generator_args = ['internal_test_gem']
  generator_args << '--skip-javascript' if ENV.fetch('RAILS_VERSION', '') >= '6.0'

  Rails::Generators::PluginGenerator.start generator_args

  if Rails.version.to_f < 6.0 || Rails.version.to_f == 6.0
    gemspec_file_path = "#{pwd}/internal_test_gem/.engine_cart.yml"
    File.open(gemspec_file_path, 'w') do |f|
      f.write('rails_options: "--skip-javascript"')
    end
  end

  Dir.chdir(pwd)

  system("mv #{Dir.pwd}/internal_test_gem #{Dir.pwd}/.internal_test_gem")

  IO.write(".internal_test_gem/internal_test_gem.gemspec", File.open(".internal_test_gem/internal_test_gem.gemspec") {|f| f.read.gsub(/FIXME/, "DONTCARE")})
  IO.write(".internal_test_gem/internal_test_gem.gemspec", File.open(".internal_test_gem/internal_test_gem.gemspec") {|f| f.read.gsub(/TODO/, "DONTCARE")})
  IO.write(".internal_test_gem/internal_test_gem.gemspec", File.open(".internal_test_gem/internal_test_gem.gemspec") {|f| f.read.gsub(/.*homepage.*/, "")})
  IO.write(".internal_test_gem/internal_test_gem.gemspec", File.open(".internal_test_gem/internal_test_gem.gemspec") {|f| f.read.gsub(/.*sqlite3.*/, "")})

  if Rails.version.to_f < 6.0 || Rails.version.to_f == 6.0
    gemspec_file_path = ".internal_test_gem/internal_test_gem.gemspec"
    IO.write(gemspec_file_path,
             File.open(gemspec_file_path) { |f|
                f.read.gsub(/(spec.add_dependency "rails".+$)/, "\\1\n  spec.add_dependency 'sprockets', '~> 3.7'")
             })
  end

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

    Bundler.clean_system "bundle update --quiet"
    system "echo 'require \"engine_cart/rake_task\"\n' >> Rakefile"

    system("bundle exec rake engine_cart:prepare")
    Bundler.clean_system "bundle install --quiet"
    system("bundle update --conservative sprockets")
  end
end

task :default => :ci
