source 'https://rubygems.org'

# Specify your gem's dependencies in engine_cart.gemspec
gemspec

gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']

case ENV['RAILS_VERSION']
when /^5\./
  gem 'sass-rails', '~> 5.0'
end
