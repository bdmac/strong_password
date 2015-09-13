require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require 'bundler/setup'
require 'pry'
require 'active_model'
require 'strong_password'

RSpec.configure do |config|
  config.expect_with(:rspec) {|c| c.syntax = :expect}
  config.order = :random
end
