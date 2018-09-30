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
  gem "rspec", "~> 3.8"
  gem "simplecov", "~> 0.16.1"
  gem "simplecov-console", "~> 0.4.2"
end
