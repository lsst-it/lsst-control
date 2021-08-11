# frozen_string_literal: true

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

ruby_version_segments = Gem::Version.new(RUBY_VERSION.dup).segments
minor_version = ruby_version_segments[0..1].join('.')

group :test do
  gem "puppet-module-posix-default-r#{minor_version}", '~> 1.1', require: false, platforms: [:ruby]
  gem "puppet-module-posix-dev-r#{minor_version}", '~> 1.1',     require: false, platforms: [:ruby]
  gem 'puppet-lint-legacy_facts-check', '~> 1.0.4',              require: false
  gem 'puppet-lint-manifest_whitespace-check', '~> 0.1.17',      require: false
  gem 'puppet-lint-no_erb_template-check', '~> 1.0.0',           require: false
  gem 'puppet-lint-package_ensure-check', '~> 0.2.0',            require: false
  gem 'puppet-lint-resource_reference_syntax', '~> 1.1.0',       require: false
  gem 'puppet-lint-strict_indent-check', '~> 2.0.8',             require: false
  gem 'puppet-lint-template_file_extension-check', '~> 0.1.3',   require: false
  gem 'puppet-lint-top_scope_facts-check', '~> 1.0.1',           require: false
  gem 'puppet-lint-trailing_newline-check', '~> 1.1.0',          require: false
  gem 'puppet-lint-unquoted_string-check', '~> 2.1.0',           require: false
  gem 'puppet-lint-variable_contains_upcase', '~> 1.2.0',        require: false
  gem 'r10k',                                                    require: false
  gem 'rubocop', '~> 1.6.1',                                     require: false
  gem 'rubocop-i18n', '~> 3.0.0',                                require: false
end

puppet_version = ENV['PUPPET_GEM_VERSION'] || '~> 6.0'
facter_version = ENV['FACTER_GEM_VERSION']
hiera_version = ENV['HIERA_GEM_VERSION']

gem 'facter', facter_version, require: false, groups: [:test]
gem 'hiera', hiera_version,   require: false, groups: [:test]
gem 'puppet', puppet_version, require: false, groups: [:test]

# vim: syntax=ruby
