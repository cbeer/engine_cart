require 'rails/generators'
require 'fileutils'

class TestAppGenerator < Rails::Generators::Base

  def create_a_dummy_git_and_gitignore_in_the_test_app
    system('git init')
    FileUtils.touch('.gitignore')
  end

  def generate_engine_cart_test_app
    generate 'engine_cart'
  end
end