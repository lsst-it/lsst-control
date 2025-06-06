# frozen_string_literal: true

task default: %w[
  check:symlinks
  check:git_ignore
  check:dot_underscore
  check:test_file
  rubocop
  syntax
  lint
  metadata_lint
  r10k:check
  r10k:install
  parallel_spec
]

# Attempt to load voxpupuli-test (which pulls in puppetlabs_spec_helper),
# otherwise attempt to load it directly.
# rubocop:disable Lint/SuppressedException
begin
  require 'voxpupuli/test/rake'
rescue LoadError
  begin
    require 'puppetlabs_spec_helper/rake_tasks'
  rescue LoadError
  end
end

# load optional tasks for acceptance
# only available if gem group releases is installed
begin
  require 'voxpupuli/acceptance/rake'
rescue LoadError
end

# load optional tasks for releases
# only available if gem group releases is installed
begin
  require 'voxpupuli/release/rake_tasks'
rescue LoadError
end
# rubocop:enable Lint/SuppressedException

desc "Run main 'test' task and report merged results to coveralls"
task test_with_coveralls: [:test] do
  if Dir.exist?(File.expand_path('lib', __dir__))
    require 'coveralls/rake/task'
    Coveralls::RakeTask.new
    Rake::Task['coveralls:push'].invoke
  else
    puts 'Skipping reporting to coveralls.  Module has no lib dir'
  end
end

desc 'Generate REFERENCE.md'
task :reference, [:debug, :backtrace] do |_t, args|
  patterns = ''
  Rake::Task['strings:generate:reference'].invoke(patterns, args[:debug], args[:backtrace])
end

PuppetLint::RakeTask.new :lint do |config|
  config.fail_on_warnings = true
end

PuppetLint.configuration.send('disable_relative')
PuppetLint.configuration.send('disable_manifest_whitespace_closing_bracket_after')

namespace :r10k do
  desc 'Create puppet module fixtures using r10k'
  task :install do
    sh("r10k puppetfile install --verbose --moduledir=#{Dir.pwd}/spec/fixtures/modules")
  end

  desc 'Check Puppetfile using r10k'
  task :check do
    sh('r10k puppetfile check --verbose')
  end
end

# vim: syntax=ruby
