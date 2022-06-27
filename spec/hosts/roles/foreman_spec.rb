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

  it { is_expected.to contain_foreman_global_parameter('bootloader-append').with_value('nofb') }
  it { is_expected.to contain_foreman_global_parameter('disable-firewall').with_value(true) }
  it { is_expected.to contain_foreman_global_parameter('enable-epel').with_value(true) }
  it { is_expected.to contain_foreman_global_parameter('enable-puppetlabs-puppet6-repo').with_value(true) }
  it { is_expected.to contain_foreman_global_parameter('host_registration_insights').with_value(false) }
  it { is_expected.to contain_foreman_global_parameter('host_registration_remote_execution').with_value(true) }
  it { is_expected.to contain_foreman_global_parameter('org').with_ensure('absent') }
  it { is_expected.to contain_foreman_global_parameter('package_upgrade').with_value(true) }
  it { is_expected.to contain_foreman_global_parameter('selinux-mode').with_value('disabled') }
  it { is_expected.to contain_foreman_global_parameter('fips_enabled').with_value(true) }
  it { is_expected.to contain_foreman_global_parameter('role').with_value('generic') }

  it do
    is_expected.to contain_foreman_global_parameter('ntp-server')
      .with_value(ntpservers.join(','))
  end

  it { is_expected.to contain_class('dhcp').with_ntpservers(ntpservers) }

  it { is_expected.to contain_foreman_config_entry('template_sync_branch').with_value(site) }
  it { is_expected.to contain_foreman_global_parameter('site').with_value(site) }
  it { is_expected.to contain_foreman_hostgroup(site) }

  {
    template_sync_associate: 'always',
    template_sync_commit_msg: 'Templates export made by a Foreman user',
    template_sync_dirname: '/',
    template_sync_filter: '',
    template_sync_force: true,
    template_sync_lock: 'unlock',
    template_sync_metadata_export_mode: 'refresh',
    template_sync_negate: false,
    template_sync_prefix: '',
    template_sync_repo: 'ssh://git@github.com/lsst-it/foreman_templates',
    template_sync_verbose: true,
  }.each do |k, v|
    it { is_expected.to contain_foreman_config_entry(k).with_value(v) }
  end

  it { is_expected.to contain_foreman_config_entry('template_sync_branch').with_value(site) }
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
    let(:ntpservers) do
      %w[
        ntp.shoa.cl
        ntp.cp.lsst.org
        1.cl.pool.ntp.org
        1.south-america.pool.ntp.org
      ]
    end

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic foreman'

    it { is_expected.to contain_foreman_global_parameter('site').with_value('dev') }
    it { is_expected.to contain_foreman_hostgroup('dev') }
  end # host

  describe 'foreman.tu.lsst.org', :site, :common do
    let(:site) { 'tu' }
    let(:ntpservers) do
      %w[
        140.252.1.140
        140.252.1.141
        140.252.1.142
      ]
    end

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic foreman'

    it { is_expected.to contain_foreman_global_parameter('site').with_value('tu') }
    it { is_expected.to contain_foreman_hostgroup('tu') }
  end # host

  describe 'foreman.ls.lsst.org', :site, :common do
    let(:site) { 'ls' }
    let(:ntpservers) do
      %w[
        ntp.shoa.cl
        ntp.cp.lsst.org
        1.cl.pool.ntp.org
        1.south-america.pool.ntp.org
      ]
    end

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic foreman'

    it { is_expected.to contain_foreman_global_parameter('site').with_value('ls') }
    it { is_expected.to contain_foreman_hostgroup('ls') }
  end # host

  describe 'foreman.cp.lsst.org', :site, :common do
    let(:site) { 'cp' }
    let(:ntpservers) do
      %w[
        ntp.cp.lsst.org
        ntp.shoa.cl
        1.cl.pool.ntp.org
        1.south-america.pool.ntp.org
      ]
    end

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic foreman'

    it { is_expected.to contain_foreman_global_parameter('site').with_value('cp') }
    it { is_expected.to contain_foreman_hostgroup('cp') }
  end # host
end # role
