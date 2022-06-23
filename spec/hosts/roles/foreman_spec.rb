# frozen_string_literal: true

require 'spec_helper'

FOREMAN_VERSION = '3.2.1'
PUPPETSERVER_VERSION = '6.19.0'
TERMINI_VERSION = '6.19.1'

shared_examples 'generic foreman' do
  include_examples 'debugutils'

  it do
    is_expected.to contain_class('foreman').with(
      version: FOREMAN_VERSION,
    )
  end

  it do
    is_expected.to contain_class('foreman::repo').with(
      repo: '3.2',
    )
  end

  it { is_expected.to contain_foreman__plugin('puppet') }
  it { is_expected.to contain_foreman__cli__plugin('foreman_puppet') }
  it { is_expected.to contain_foreman__plugin('tasks') }
  it { is_expected.to contain_foreman__cli__plugin('foreman_tasks') }
  it { is_expected.to contain_foreman__plugin('remote_execution') }
  it { is_expected.to contain_foreman__cli__plugin('foreman_remote_execution') }
  it { is_expected.to contain_foreman__plugin('templates') }
  it { is_expected.to contain_foreman__cli__plugin('foreman_templates') }
  it { is_expected.to contain_foreman__plugin('column_view') }

  [
    "0:foreman-cli-#{FOREMAN_VERSION}-1.el7.noarch",
    "0:foreman-debug-#{FOREMAN_VERSION}-1.el7.noarch",
    "0:foreman-dynflow-sidekiq-#{FOREMAN_VERSION}-1.el7.noarch",
    "0:foreman-#{FOREMAN_VERSION}-1.el7.noarch",
    "0:foreman-libvirt-#{FOREMAN_VERSION}-1.el7.noarch",
    "0:foreman-postgresql-#{FOREMAN_VERSION}-1.el7.noarch",
    "0:foreman-service-#{FOREMAN_VERSION}-1.el7.noarch",
    "0:puppetdb-termini-#{TERMINI_VERSION}-1.el7.noarch",
    "0:puppetserver-#{PUPPETSERVER_VERSION}-1.el7.noarch",
    "1:foreman-installer-#{FOREMAN_VERSION}-1.el7.noarch",
    "0:foreman-proxy-#{FOREMAN_VERSION}-1.el7.noarch",
    "0:foreman-vmware-#{FOREMAN_VERSION}-1.el7.noarch",
  ].each do |pkg|
    it { is_expected.to contain_yum__versionlock(pkg) }
  end

  it { is_expected.to contain_class('foreman_proxy::plugin::dynflow') }
  it { is_expected.to contain_class('puppetdb::globals').with_version(TERMINI_VERSION) }

  it do
    is_expected.to contain_class('puppet').with(
      server_puppetserver_version: PUPPETSERVER_VERSION,
      server_version: PUPPETSERVER_VERSION,
    )
  end

  it 'has global ProxyCommand knocked out with --' do
    expect(catalogue.resource('class', 'ssh')[:client_options]).to include(
      'ProxyCommand' => '',
    )
  end

  it 'has foreman & foreman-proxy user exempt from ProxyCommand' do
    expect(catalogue.resource('class', 'ssh')[:client_match_block]).to include(
      'foreman,foreman-proxy' => {
        'type' => '!localuser',
        'options' => {
          'ProxyCommand' => '/usr/bin/sss_ssh_knownhostsproxy -p %p %h',
        },
      },
    )
  end

  it { is_expected.to contain_foreman_config_entry('host_details_ui').with_value(false) }
end

describe 'foreman role' do
  let(:node_params) do
    {
      role: 'foreman',
      site: site,
    }
  end

  let(:facts) { { fqdn: self.class.description } }

  describe 'foreman.dev.lsst.org', :site, :common do
    let(:site) { 'dev' }

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic foreman'
  end # host

  describe 'foreman.tu.lsst.org', :site, :common do
    let(:site) { 'tu' }

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic foreman'
  end # host

  describe 'foreman.ls.lsst.org', :site, :common do
    let(:site) { 'ls' }

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic foreman'
  end # host

  describe 'foreman.cp.lsst.org', :site, :common do
    let(:site) { 'cp' }

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic foreman'
  end # host
end # role
