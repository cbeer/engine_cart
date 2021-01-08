source 'https://rubygems.org'

# Specify your gem's dependencies in engine_cart.gemspec
gemspec

gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']

case ENV['RAILS_VERSION']
when /^6.0/
  gem 'sass-rails', '>= 6'
  gem 'webpacker', '~> 4.0'
when /^5.[12]/
  gem 'sprockets', '< 4.0'
  gem 'sass-rails', '~> 5.0'
  gem 'thor', '~> 0.20'
end
