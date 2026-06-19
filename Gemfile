# frozen_string_literal: true

# Tells RubyGems where to download gems from.
source 'https://rubygems.org'

# Pin the Ruby version so every contributor (and CI) uses the same one.
ruby '3.4.6'

group :development, :test do
  # RSpec — our test framework. The "~> 3.13" means "3.13 or any 3.x above it,
  # but not 4.0". This protects us from breaking major-version changes.
  gem 'rspec', '~> 3.13'

  # RuboCop — a static analysis tool that enforces Ruby style guidelines.
  # "require: false" means it's never auto-loaded by the app itself.
  gem 'rubocop', '~> 1.65', require: false

  # Adds RuboCop rules specifically for RSpec files (spec/ directory).
  gem 'rubocop-rspec', '~> 3.0', require: false
end
