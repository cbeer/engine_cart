require 'spec_helper'

describe "EngineCart powered application" do
  EngineCart.destination = File.expand_path("../../.internal_test_gem", File.dirname(__FILE__))

  it "should have the test_app_templates pre-generated" do
    expect(File).to exist File.expand_path("spec/test_app_templates", EngineCart.destination)
  end

  it "should ignore the test app" do
    git_ignore = File.expand_path(".gitignore", EngineCart.destination)
    expect(File.read(git_ignore)).to match /.internal_test_app/
  end

  it "should have a engine_cart:generate rake task available" do
    EngineCart.within_test_app do
      `rake -T | grep "engine_cart:generate"`
      expect($?).to eq 0
    end
  end

  it "should have a engine_cart:regenerate rake task available" do
    EngineCart.within_test_app do
      `rake -T | grep "engine_cart:regenerate"`
      expect($?).to eq 0
    end
  end

  it "should create a rails app when the engine_cart:generate task is invoked" do
    EngineCart.within_test_app do
      `rake engine_cart:generate`
      expect(File).to exist(File.expand_path('.internal_test_app'))
    end
  end

  it "should not recreate an existing rails app when the engine_cart:generate task is reinvoked" do
    EngineCart.within_test_app do
      `rake engine_cart:generate`
      expect(File).to exist(File.expand_path('.internal_test_app'))
      FileUtils.touch File.join('.internal_test_app', ".this_should_still_exist")
      `rake engine_cart:generate`
      expect(File).to exist(File.expand_path(File.join('.internal_test_app', ".this_should_still_exist")))
    end
  end
  
  it "should create a rails app when the fingerprint argument is changed" do
    EngineCart.within_test_app do
      `rake engine_cart:generate[this-fingerprint]`
      expect(File).to exist(File.expand_path('.internal_test_app'))
      FileUtils.touch File.join('.internal_test_app', ".this_should_not_exist")
      `rake engine_cart:generate[that-fingerprint]`
      expect(File).to_not exist(File.expand_path(File.join('.internal_test_app', ".this_should_not_exist")))
    end
  end
  
  it "should be able to test the application controller from the internal app" do
    EngineCart.within_test_app do
      File.open('spec/some_spec.rb', 'w') do |f|
        f.puts <<-EOF
          require 'spec_helper'

          describe ApplicationController do
            it "should be able to test the application controller from the internal app" do
              expect(subject).to be_a_kind_of(ActionController::Base)
            end
          end

        EOF
      end

      `bundle exec rspec spec/some_spec.rb`
      expect($?).to eq 0
    end
  end

  it "should be able to run specs that reference gems provided by the test app" do
    EngineCart.within_test_app do
      File.open('spec/require_spec.rb', 'w') do |f|
        f.puts <<-EOF
          require 'spec_helper'
          require 'coffee-rails'

          describe ApplicationController do
            it "should be able to run specs that reference gems provided by the test app" do
              expect(true).to be_truthy
            end
          end

        EOF
      end

      `bundle exec rspec spec/require_spec.rb`
      expect($?).to eq 0
    end
  end
end
