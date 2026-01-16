require 'simplecov'
require 'simplecov-cobertura'
require 'policy_assertions'

SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
SimpleCov.start
# Previous content of test helper now starts here
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/rails/capybara"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  #include Devise::Test::ControllerHelpers
  # Add more helper methods to be used by all tests here...
end
