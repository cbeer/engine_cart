source 'https://rubygems.org'

# Specify your gem's dependencies in engine_cart.gemspec
gemspec

gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']

case ENV['RAILS_VERSION']
when /^6\./
  # This will only be necessary until release 6.0.1 is published (please see 
  # https://github.com/rails/rails/issues/36954#issuecomment-522171807)
  gem 'sass-rails', '~> 6.0'
when /^5\./
  gem 'sprockets', '~> 3.7'
end
