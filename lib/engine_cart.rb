require 'engine_cart/configuration'
require 'engine_cart/fingerprint'
require 'engine_cart/version'
require 'engine_cart/gemfile_stanza'
require 'bundler'

module EngineCart
  require 'engine_cart/engine' if defined? Rails

  def self.load_application!(path = nil)
    require File.expand_path('config/environment', path || EngineCart.destination)
  end

  def self.within_test_app
    Dir.chdir(EngineCart.destination) do
      Bundler.with_clean_env do
        yield
      end
    end
  end

  def self.update?(fingerprint)
    return true if EngineCart.fingerprint_saved.nil? || fingerprint.nil?
    EngineCart.fingerprint_saved != fingerprint
  end

  def self.configuration(options = {})
    @configuration ||= EngineCart::Configuration.new(options)
  end

  class << self
    %w(destination engine_name templates_path template rails_options).each do |method|
      define_method(method) do
        configuration.send(method)
      end
    end
  end

  def self.check_for_gemfile_stanza
    return unless File.exist? 'Gemfile'

    unless File.readlines('Gemfile').grep(/#{EngineCart.gemfile_stanza_check_line}/).any?
      Bundler.ui.warn "[EngineCart] For better results, consider updating the EngineCart stanza in your Gemfile with:\n\n"
      Bundler.ui.warn EngineCart.gemfile_stanza_text
    end
  end
end
