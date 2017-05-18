require 'bundler'
require 'digest/md5'

module EngineCart

  def self.fingerprint_current
    (@fingerprint_proc || method(:default_fingerprint)).call
  end

  def self.fingerprint_saved
    File.read(EngineCart.fingerprint_file)
  rescue StandardError
    nil
  end

  def self.fingerprint_save(fp)
    fp ||= EngineCart.fingerprint_current
    File.open(EngineCart.fingerprint_file, 'w') { |f| f.write(fp) }
  end

  def self.fingerprint_update
    EngineCart.fingerprint = EngineCart.fingerprint_current
    EngineCart.fingerprint_save EngineCart.fingerprint
  end

  def self.fingerprint_file
    File.expand_path('.generated_engine_cart', EngineCart.destination)
  end

  def self.fingerprint
    @fingerprint || EngineCart.fingerprint_current
  end

  def self.fingerprint=(fp)
    @fingerprint = fp
  end

  def self.fingerprint_proc=(fingerprint_proc)
    @fingerprint_proc = fingerprint_proc
  end

  def self.rails_fingerprint_proc(extra_files = [])
    lambda do
      EngineCart.default_fingerprint + EngineCart.rails_fingerprint(extra_files)
    end
  end

  def self.rails_fingerprint(extra_files = [])
    EngineCart.files_digest(EngineCart.rails_files + extra_files)
  end

  def self.rails_files
    Dir.glob([
      './db/migrate/*',
      './lib/generators/**/**',
      './spec/test_app_templates/**/**'
    ])
  end

  def self.default_fingerprint
    EngineCart.env_fingerprint + EngineCart.gem_fingerprint
  end

  def self.gem_fingerprint
    EngineCart.files_digest EngineCart.gem_files
  end

  def self.gem_files
    Dir.glob('./*.gemspec') + [EngineCart.bundle_gemfile, EngineCart.bundle_lockfile]
  end

  def self.env_fingerprint
    {
      'RUBY_DESCRIPTION' => RUBY_DESCRIPTION,
      'BUNDLE_GEMFILE' => EngineCart.bundle_gemfile
    }.reject { |k, v| v.nil? || v.empty? }.to_s
  end

  def self.bundle_gemfile
   @bundle_gemfile ||= Bundler.default_gemfile.to_s
  end

  def self.bundle_lockfile
    @bundle_gemfile ||= Bundler.default_lockfile.to_s
  end

  def self.files_digest(files)
    files_digests = files.collect {|f| file_digest(f) }.join
    Digest::MD5.hexdigest(files_digests)
  end

  def self.file_digest(f)
    File.file?(f) ? Digest::MD5.hexdigest(File.read(f)) : ''
  end

end
