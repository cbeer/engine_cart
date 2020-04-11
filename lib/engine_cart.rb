require 'engine_cart/configuration'
require "engine_cart/version"
require 'engine_cart/gemfile_stanza'
require 'bundler'
require 'json'
require 'digest'

module EngineCart
  require "engine_cart/engine" if defined? Rails

  def self.load_application! path = nil
    require File.expand_path("config/environment", path || EngineCart.destination)
  end

  def self.with_unbundled_env
    method = if Bundler.respond_to?(:with_unbundled_env)
      :with_unbundled_env
    else
      :with_clean_env
    end

    Bundler.public_send(method) do
      yield
    end
  end

  def self.within_test_app
    Dir.chdir(EngineCart.destination) do
      EngineCart.with_unbundled_env do
        yield
      end
    end
  end

  def self.fingerprint_expired?
    !fingerprint_current?
  end

  def self.fingerprint_current?

    unless File.exist? stored_fingerprint_file
      STDERR.puts "No finger print file found: #{stored_fingerprint_file}" if debug?
      return false
    end
    content = File.read(stored_fingerprint_file)
    data = JSON.parse(content, symbolize_names: true)
    calculated = fingerprint

    return true if data == calculated
    if debug?
      STDERR.puts "Fingerprint mismatch:\n\n"

      data.keys.each do |key|
        case data[key]
        when Array
          data[key].zip(calculated[key]).each do |(stored, calc)|
            STDERR.puts("#{key}:\nstored: #{stored}\ncalculate: #{calc}") if stored != calc
          end
        else
          STDERR.puts("#{key}:\nstored: #{data[key]}\ncalculate: #{calculated[key]}") if data[key] != calculated[key]
        end
      end
    end

    false
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
      [Bundler.default_gemfile.to_s] +
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
    { RUBY_DESCRIPTION: RUBY_DESCRIPTION, BUNDLE_GEMFILE: Bundler.default_gemfile.to_s }.reject { |k, v| v.nil? || v.empty? }
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

  def self.debug=(debug)
    @debug = debug
  end

  def self.debug?
    @debug
  end
end
