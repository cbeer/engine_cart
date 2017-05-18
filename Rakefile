require "bundler/gem_tasks"
require 'engine_cart/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :ci

task :ci => ['generate_test_gem', 'spec'] do

end

task :generate_test_gem => ['engine_cart:setup'] do
  destination = EngineCart.destination

  system("rm -rf #{destination}")

  if ENV['RAILS_VERSION']
    gem 'rails', ENV['RAILS_VERSION']
  else
    gem 'rails'
  end

  Bundler.with_clean_env do
    system('bundle exec rails plugin new /tmp/internal_test_gem')
  end
  system("mv /tmp/internal_test_gem #{destination}")

  IO.write("#{destination}/internal_test_gem.gemspec", File.open("#{destination}/internal_test_gem.gemspec") {|f| f.read.gsub(/FIXME/, "DONTCARE")})
  IO.write("#{destination}/internal_test_gem.gemspec", File.open("#{destination}/internal_test_gem.gemspec") {|f| f.read.gsub(/TODO/, "DONTCARE")})
  IO.write("#{destination}/internal_test_gem.gemspec", File.open("#{destination}/internal_test_gem.gemspec") {|f| f.read.gsub(/.*homepage.*/, "")})

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
    if Gem.loaded_specs["rails"].version.to_s < '4.2'
      system %Q{echo '\ngem "sass", "~> 3.2.15"\n' >> Gemfile}
      system %Q{echo '\ngem "sprockets", "~> 2.11.0"\n' >> Gemfile}
    end
    Bundler.clean_system "bundle update --quiet"

    system "echo 'require \"engine_cart/rake_task\"\n' >> Rakefile"
    system("bundle exec rake engine_cart:prepare")
    Bundler.clean_system "bundle install --quiet"
  end
end

