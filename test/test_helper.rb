# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails/test_help"
require "minitest/reporters"
require 'factory_girl'

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

class Minitest::Unit::TestCase
  include FactoryGirl::Syntax::Methods
end

FactoryGirl.find_definitions