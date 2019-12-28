source 'https://rubygems.org'

# Specify your gem's dependencies in engine_cart.gemspec
gemspec

gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']
# Rails requires sprockets, but the Gemfile it generates has sass-rails 5, which requires sprockets < 4
gem 'sprockets', '< 4.0' if ENV['RAILS_VERSION'].start_with?('5')
