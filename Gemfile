# frozen_string_literal: true

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  gem 'coveralls',                 require: false
  gem 'puppet_metadata', '~> 4.0', require: false
  gem 'simplecov-console',         require: false
  gem 'voxpupuli-test', '~> 9.0',  require: false

  gem 'librarian-puppet',                             require: false
  gem 'puppet-lint-package_ensure-check', '~> 0.2.0', require: false
  gem 'r10k',                                         require: false
end

group :development do
  gem 'guard-rake',              require: false
  gem 'overcommit', '>= 0.39.1', require: false
end

group :system_tests do
  gem 'voxpupuli-acceptance', '~> 3.0', require: false
end

group :release do
  gem 'voxpupuli-release', '~> 3.0', require: false
end

gem 'facter', ENV.fetch('FACTER_GEM_VERSION', nil), require: false, groups: [:test]
gem 'rake', require: false

puppetversion = ENV['PUPPET_GEM_VERSION'] || '~> 8.9'
gem 'puppet', puppetversion, require: false, groups: [:test]

# vim: syntax=ruby
