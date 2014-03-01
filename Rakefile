require "bundler/gem_tasks"
require 'engine_cart/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :ci => ['generate_test_gem', 'spec'] do

end

task :generate_test_gem => ['engine_cart:setup'] do
  system("rm -rf spec/internal")
  system("rails plugin new spec/internal_gem")
  system("mv spec/internal_gem spec/internal")
  Rake::Task['engine_cart:inject_gemfile_extras'].invoke
  EngineCart.within_test_app do
    system "git init"
    FileUtils.touch('.gitignore')
    Dir.mkdir('spec')
    system "bundle install"
    system "echo 'require \"engine_cart/rake_task\"\n' >> Rakefile"

    system("rake engine_cart:prepare")
    system("rake engine_cart:generate")
  end
end

task :default => :ci
