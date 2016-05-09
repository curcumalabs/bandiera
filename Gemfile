source 'https://rubygems.org'

gem 'rake'
gem 'dotenv'

gem 'sequel'
gem 'mysql2', platform: :ruby
gem 'jdbc-mysql', platform: :jruby

gem 'sinatra'
gem 'rack-flash3'
gem 'erubis'
gem 'macmillan-utils'

gem 'unicorn', require: false, platform: :ruby
gem 'puma', require: false

gem 'airbrake', require: false
gem 'statsd-ruby', require: false
gem 'newrelic_rpm'

group :development do
  gem 'shotgun'
  gem 'rubocop'
end

group :test do
  gem 'sqlite3', platform: :ruby
  gem 'jdbc-sqlite3', platform: :jruby
  gem 'rspec'
  gem 'rack-test'
  gem 'capybara'
  gem 'poltergeist'
  gem 'webmock'
  gem 'pry'
  gem 'guard-rspec', require: false
end

group :deploy do
  gem 'capistrano',           '~> 3.4'
  gem 'capistrano-bundler',   '~> 1.1'
  gem 'capistrano-passenger', '~> 0.1'
  gem 'capistrano-rbenv',     '~> 2.0'
end
