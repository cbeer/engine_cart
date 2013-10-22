require 'spec_helper'

describe "EngineCart powered application" do
  TEST_APP = File.expand_path("../internal", File.dirname(__FILE__))
  it "should have the test_app_templates pre-generated" do
    expect(File).to exist File.expand_path("spec/test_app_templates", TEST_APP)
  end

  it "should ignore the test app" do
    git_ignore = File.expand_path(".gitignore", TEST_APP)
    expect(File.read(git_ignore)).to match /spec\/internal/
  end

  it "should have a engine_cart:generate rake task available" do

  end

  it "should create a rails app when the engine_cart:generate is invoked" do

  end
end