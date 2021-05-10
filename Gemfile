source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

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
  gem "simplecov", require: false
  gem "simplecov-console", require: false
end
