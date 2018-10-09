source 'https://rubygems.org'

gemspec

version = ENV["RAILS_VERSION"] || "4.2"

rails = case version
when "master"
  {github: "rails/rails"}
else
  "~> #{version}.0"
end

gem "rails", rails
group :test do
  gem "simplecov", "~> 0.16.1", require: false
  gem "simplecov-console", "~> 0.4.2", require: false
end
