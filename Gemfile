source 'https://rubygems.org'

# Specify your gem's dependencies in engine_cart.gemspec
gemspec

gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']

if ENV['RAILS_VERSION'] && ENV['RAILS_VERSION'] < '4.2'
  gem 'sass', '~> 3.2.15'
  gem 'sprockets', '~> 2.11.0'
end
