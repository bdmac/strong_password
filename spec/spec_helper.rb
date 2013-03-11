require 'bundler/setup'
require 'strong_password'
require 'active_model'

RSpec.configure do |config|
  config.expect_with(:rspec) {|c| c.syntax = :expect}
  config.order = :random
end