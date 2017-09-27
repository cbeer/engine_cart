require 'yaml'
require 'erb'

module EngineCart
  class Configuration
    attr_reader :options

    def initialize(options = {})
      @verbose = options[:verbose]

      @options = load_configs(Array[options[:config]]).merge(options)
    end

    def load_configs(config_files)
      config = default_config

      (default_configuration_paths + config_files.compact).each do |p|
        path = File.expand_path(p)
        next unless File.exist? path
        config.merge!(read_config(path))
      end

      config
    end

    ##
    # Name of the engine we're testing
    def engine_name
      options[:engine_name]
    end

    ##
    # Destination to generate the test app into
    def destination
      options[:destination]
    end

    ##
    # Path to a Rails application template
    def template
      options[:template]
    end

    ##
    # Path to test app templates to make available to
    # the test app generator
    def templates_path
      options[:templates_path]
    end

    ##
    # Additional options when generating a test rails application
    def rails_options
      Array(options[:rails_options])
    end

    def default_destination
      '.internal_test_app'
    end

    def default_engine_name
      File.basename(Dir.glob('*.gemspec').first, '.gemspec')
    end

    def verbose?
      @verbose || (options && !!options.fetch(:verbose, false))
    end

    private

    def default_config
      {
        engine_name: ENV['CURRENT_ENGINE_NAME'] || default_engine_name,
        destination: ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || default_destination,
        template: ENV['ENGINE_CART_TEMPLATE'],
        templates_path: ENV['ENGINE_CART_TEMPLATES_PATH'] || './spec/test_app_templates',
        rails_options: parse_options(ENV['ENGINE_CART_RAILS_OPTIONS'])
      }
    end

    # Split a string of options into individual options.
    # @example
    #   parse_options('--skip-foo --skip-bar -d postgres --skip-lala')
    #   # => ["--skip-foo", "--skip-bar", "-d postgres", "--skip-lala"]
    def parse_options(options)
      return if options.nil?
      options.scan(/(--[^\s]+|-[^\s]+\s+[^\s]+)/).flatten
    end

    def read_config(config_file)
      $stdout.puts "Loading configuration from #{config_file}" if verbose?
      config = YAML.load(ERB.new(IO.read(config_file)).result(binding))
      unless config
        $stderr.puts "Unable to parse config #{config_file}" if verbose?
        return {}
      end
      convert_keys(config)
    end

    def convert_keys(hash)
      hash.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
    end

    def default_configuration_paths
      ['~/.engine_cart.yml', '.engine_cart.yml']
    end
  end
end
