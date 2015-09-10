require "bundler/gem_tasks"
require 'engine_cart/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :ci => ['generate_test_gem', 'spec'] do

end

task :generate_test_gem => ['engine_cart:setup'] do
  system("rm -rf spec/internal")
  gem 'rails'

  version = if Gem.loaded_specs["rails"]
              "_#{Gem.loaded_specs["rails"].version}_"
            end

  Bundler.with_clean_env do
    system("rails #{version} plugin new spec/internal_gem")
  end

  IO.write("spec/internal_gem/internal_gem.gemspec", File.open("spec/internal_gem/internal_gem.gemspec") {|f| f.read.gsub(/FIXME/, "DONTCARE")})
  IO.write("spec/internal_gem/internal_gem.gemspec", File.open("spec/internal_gem/internal_gem.gemspec") {|f| f.read.gsub(/TODO/, "DONTCARE")})
  IO.write("spec/internal_gem/internal_gem.gemspec", File.open("spec/internal_gem/internal_gem.gemspec") {|f| f.read.gsub(/.*homepage.*/, "")})

  system("mv spec/internal_gem spec/internal")
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
        require 'rspec/autorun'

        require 'internal_gem'
        RSpec.configure do |config|

        end
      EOF
    end

    system "echo '\ngem \"rspec-rails\"\n' >> Gemfile"
    system %Q{echo '\ngem "sass", "~> 3.2.15"\n' >> Gemfile}
    system %Q{echo '\ngem "sprockets", "~> 2.11.0"\n' >> Gemfile}
    system "bundle update"
    system "echo 'require \"engine_cart/rake_task\"\n' >> Rakefile"

    system("rake engine_cart:prepare")
    system "bundle install"
  end
end

task :default => :ci
