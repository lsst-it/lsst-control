source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place_or_version, fake_version = nil)
  git_url_regex = %r{\A(?<url>(https?|git)[:@][^#]*)(#(?<branch>.*))?}
  file_url_regex = %r{\Afile:\/\/(?<path>.*)}

  if place_or_version && (git_url = place_or_version.match(git_url_regex))
    [fake_version, { git: git_url[:url], branch: git_url[:branch], require: false }].compact
  elsif place_or_version && (file_url = place_or_version.match(file_url_regex))
    ['>= 0', { path: File.expand_path(file_url[:path]), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

ruby_version_segments = Gem::Version.new(RUBY_VERSION.dup).segments
minor_version = ruby_version_segments[0..1].join('.')

group :development do
  gem "puppet-module-posix-default-r#{minor_version}", '~> 1.1', require: false, platforms: [:ruby]
  gem "puppet-module-posix-dev-r#{minor_version}", '~> 1.1',     require: false, platforms: [:ruby]
  gem "puppet-lint-trailing_newline-check", '~> 1.1.0',          require: false
  gem "puppet-lint-variable_contains_upcase", '~> 1.2.0',        require: false
  gem "puppet-lint-strict_indent-check", '~> 2.0.8',             require: false
  gem "puppet-lint-unquoted_string-check", '~> 2.1.0',           require: false
  gem "puppet-lint-package_ensure-check", '~> 0.2.0',            require: false
  gem "puppet-lint-top_scope_facts-check", '~> 1.0.1',           require: false
  gem "puppet-lint-legacy_facts-check", '~> 1.0.4',              require: false
  gem "puppet-lint-resource_reference_syntax", '~> 1.1.0',       require: false
  gem "puppet-lint-no_erb_template-check", '~> 1.0.0',           require: false
  gem "puppet-lint-template_file_extension-check", '~> 0.1.3',   require: false
end

puppet_version = ENV['PUPPET_GEM_VERSION']
facter_version = ENV['FACTER_GEM_VERSION']
hiera_version = ENV['HIERA_GEM_VERSION']

gems = {}

gems['puppet'] = location_for(puppet_version)

# If facter or hiera versions have been specified via the environment
# variables

gems['facter'] = location_for(facter_version) if facter_version
gems['hiera'] = location_for(hiera_version) if hiera_version

gems.each do |gem_name, gem_params|
  gem gem_name, *gem_params
end

# Evaluate Gemfile.local and ~/.gemfile if they exist
extra_gemfiles = [
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
]

extra_gemfiles.each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding)
  end
end
# vim: syntax=ruby
