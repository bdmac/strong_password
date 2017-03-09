require "codeclimate-test-reporter"
# need to fix it https://github.com/codeclimate/ruby-test-reporter/blob/master/README.md
# CodeClimate::TestReporter.start
require 'bundler/setup'
require 'pry'
require 'active_model'
require 'strong_password'

RSpec.configure do |config|
  config.expect_with(:rspec) {|c| c.syntax = :expect}
  config.order = :random
end
