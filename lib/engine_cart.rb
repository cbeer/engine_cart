require 'engine_cart/configuration'
require "engine_cart/version"
require 'engine_cart/gemfile_stanza'
require 'bundler'
require 'json'

module EngineCart
  require "engine_cart/engine" if defined? Rails

  def self.load_application! path = nil
    require File.expand_path("config/environment", path || EngineCart.destination)
  end

  def self.within_test_app
    Dir.chdir(EngineCart.destination) do
      Bundler.with_clean_env do
        yield
      end
    end
  end

  def self.fingerprint_expired?
    !fingerprint_current?
  end

  def self.fingerprint_current?
    return false unless File.exist? stored_fingerprint_file
    content = File.read(stored_fingerprint_file)
    data = JSON.parse(content, symbolize_names: true)
    data == fingerprint
  rescue
    false
  end

  def self.write_fingerprint
    File.open(stored_fingerprint_file, 'w') do |f|
      f.write(EngineCart.fingerprint.to_json)
    end
  end

  def self.stored_fingerprint_file
    File.expand_path('.generated_engine_cart', EngineCart.destination)
  end

  def self.fingerprint
    { env: env_fingerprint }.merge(files:
      fingerprinted_files.map do |file|
        { file: file, fingerprint: Digest::MD5.file(file).to_s }
      end
    )
  end

  def self.fingerprinted_files
    Dir.glob("./*.gemspec").select { |f| File.file? f } +
      [Bundler.default_gemfile.to_s, Bundler.default_lockfile.to_s] +
      Dir.glob("./db/migrate/*").select { |f| File.file? f } +
      Dir.glob("./lib/generators/**/**").select { |f| File.file? f } +
      Dir.glob("./spec/test_app_templates/**/**").select { |f| File.file? f } +
      configuration.extra_fingerprinted_files
  end

  def self.extra_fingerprinted_files=(extra_fingerprinted_files)
    @extra_fingerprinted_files = extra_fingerprinted_files
  end

  def self.extra_fingerprinted_files
    @extra_fingerprinted_files || []
  end

  def self.env_fingerprint
    { 'RUBY_DESCRIPTION' => RUBY_DESCRIPTION, 'BUNDLE_GEMFILE' => Bundler.default_gemfile.to_s }.reject { |k, v| v.nil? || v.empty? }.to_s
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
