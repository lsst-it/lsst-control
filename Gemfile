# frozen_string_literal: true

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  gem 'librarian-puppet', require: false
  gem 'r10k', require: false
  gem 'toml-rb', require: false # puppet/telegraf

  gem 'coveralls',                              require: false
  gem 'puppet-lint-package_ensure-check',       require: false
  gem 'puppet-lint-resource_reference_syntax',  require: false
  gem 'puppet-lint-strict_indent-check',        require: false
  gem 'puppet-lint-unquoted_string-check',      require: false
  gem 'puppet-lint-variable_contains_upcase',   require: false
  gem 'puppet_metadata', '~> 3.0',              require: false
  gem 'simplecov-console',                      require: false
  gem 'voxpupuli-test', '~> 7.0',               require: false
end

group :development do
  gem 'guard-rake',               require: false
  gem 'overcommit', '>= 0.39.1',  require: false
end

group :system_tests do
  gem 'voxpupuli-acceptance', '~> 2.0', require: false
end

group :release do
  gem 'faraday-retry', '~> 2.1',                  require: false
  gem 'github_changelog_generator', '>= 1.16.1',  require: false
  gem 'voxpupuli-release', '~> 3.0',              require: false
end

gem 'facter', ENV.fetch('FACTER_GEM_VERSION', nil), require: false, groups: [:test]
gem 'rake', require: false

# See: https://github.com/puppetlabs/puppet/issues/9268
puppetversion = ENV['PUPPET_GEM_VERSION'] || '~> 7.28.0'
gem 'puppet', puppetversion, require: false, groups: [:test]

# vim: syntax=ruby
