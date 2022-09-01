# frozen_string_literal: true

require 'voxpupuli/test/spec_helper'
include RspecPuppetFacts

# facterdb does not include puppetlabs/stdlib facts
add_stdlib_facts
# voxpupuli-test 5.4.1 does not include puppetlabs/stdlib package_provider fact
add_custom_fact :package_provider, 'yum', confine: 'centos-7-x86_64' # puppet/yum

def root_path
  File.expand_path(File.join(__FILE__, '..', '..'))
end

def spec_path
  File.join(root_path, 'spec')
end

def fixtures_path
  File.join(root_path, 'spec', 'fixtures')
end

def control_hiera_config
  File.join(root_path, 'hiera.yaml')
end

def control_hieradata_path
  File.join(root_path, 'hieradata')
end

def puppetfile_path
  File.join(root_path, 'Puppetfile')
end

# extract public hiera hierarchy
def public_hierarchy
  hc = YAML.load_file(control_hiera_config)
  hc['hierarchy'][1]['paths']
end

def hiera_all_files
  public_hierarchy.map { |l| hiera_files_in_layer(l) }.flatten
end

default_facts = {
  puppetversion: Puppet.version,
  facterversion: Facter.version,
}

def lsst_sites
  %w[
    dev
    ls
    cp
    tu
  ]
end

def hiera_roles
  role_dir = File.join(control_hieradata_path, 'role')
  Dir.entries(role_dir).grep_v(%r{^\.}).map { |x| x.sub('.yaml', '') }
end

# all hiera role layers
def hiera_role_layers
  public_hierarchy.grep(%r{role})
end

def hiera_files_in_layer(layer)
  yaml_glob = layer.gsub(%r{%{\w+?}}, '**')
  glob = File.join(control_hieradata_path, yaml_glob)
  Dir[glob]
end

default_fact_files = [
  File.expand_path(File.join(File.dirname(__FILE__), 'default_facts.yml')),
  File.expand_path(File.join(File.dirname(__FILE__), 'default_module_facts.yml')),
]

default_fact_files.each do |f|
  next unless File.exist?(f) && File.readable?(f) && File.size?(f)

  begin
    default_facts.merge!(YAML.safe_load(File.read(f), [], [], true))
  rescue StandardError => e
    RSpec.configuration.reporter.message "WARNING: Unable to load #{f}: #{e}"
  end
end

RSpec.configure do |c|
  c.default_facts = default_facts
  c.module_path = "#{File.join(root_path, 'site')}:#{File.join(fixtures_path, 'modules')}"
  c.hiera_config = File.join(fixtures_path, 'hiera-profile-mod.yaml')
  c.before :each do
    # set to strictest setting for testing
    # by default Puppet runs at warning level
    Puppet.settings[:strict] = :warning
  end
  c.filter_run_excluding(bolt: true) unless ENV['GEM_BOLT']
end

# Ensures that a module is defined
# @param module_name Name of the module
def ensure_module_defined(module_name)
  module_name.split('::').reduce(Object) do |last_module, next_module|
    last_module.const_set(next_module, Module.new) unless last_module.const_defined?(next_module, false)
    last_module.const_get(next_module, false)
  end
end

def node_dir
  File.join(control_hieradata_path, 'node')
end

def node_files
  Dir.children(node_dir)
end

shared_context 'with site.pp', :site do
  before(:context) do
    RSpec.configuration.manifest = File.join(root_path, 'manifests', 'site.pp')
    RSpec.configuration.hiera_config = File.join(fixtures_path, 'hiera.yaml')
  end

  after(:context) { RSpec.configuration.manifest = nil }
end

shared_examples 'krb5.conf content' do |match|
  it do
    is_expected.to contain_concat__fragment('mit_krb5::libdefaults').with(
      content: match,
    )
  end
end

shared_examples 'common', :common do |opts = {}|
  if opts[:no_auth].nil?
    include_examples 'krb5.conf content', %r{default_ccache_name = FILE:/tmp/krb5cc_%{uid}}
    include_examples 'krb5.conf content', %r{udp_preference_limit = 0}
  end

  it { is_expected.to contain_class('yum::plugin::versionlock').with_clean(true) }
  it { is_expected.to contain_yum__versionlock('puppet-agent').with_version('7.18.0') }
  it { is_expected.to contain_class('yum').with_manage_os_default_repos(true) }
  it { is_expected.to contain_resources('yumrepo').with_purge(true) }
end

shared_examples 'lhn sysctls', :lhn_node do
  it do
    is_expected.to contain_sysctl__value('net.core.rmem_max')
      .with_value(536_870_912)
  end

  it do
    is_expected.to contain_sysctl__value('net.core.wmem_max')
      .with_value(536_870_912)
  end

  it do
    is_expected.to contain_sysctl__value('net.ipv4.tcp_rmem')
      .with_value('4096 87380 536870912')
  end

  it do
    is_expected.to contain_sysctl__value('net.ipv4.tcp_wmem')
      .with_value('4096 65536 536870912')
  end

  it do
    is_expected.to contain_sysctl__value('net.ipv4.tcp_congestion_control')
      .with_value('htcp')
  end

  it do
    is_expected.to contain_sysctl__value('net.ipv4.tcp_mtu_probing')
      .with_value(1)
  end

  it do
    is_expected.to contain_sysctl__value('net.core.default_qdisc')
      .with_value('fq')
  end
end

shared_examples 'archiver', :archiver do
  %w[
    profile::archive::data
    profile::core::common
    profile::core::debugutils
    profile::core::docker
    profile::core::docker::prune
    profile::core::nfsclient
    profile::core::nfsserver
    profile::core::sysctl::lhn
    python
  ].each do |c|
    it { is_expected.to contain_class(c) }
  end
end

shared_examples 'lsst-daq sysctls' do
  it do
    is_expected.to contain_sysctl__value('net.core.rmem_max')
      .with_value(18_874_368)
  end

  it do
    is_expected.to contain_sysctl__value('net.core.wmem_max')
      .with_value(18_874_368)
  end
end

shared_examples 'lsst-daq client' do
  include_examples 'lsst-daq sysctls'

  it do
    is_expected.to contain_network__interface('lsst-daq').with(
      bootproto: 'dhcp',
    )
  end
end

shared_examples 'nfsv2 enabled' do
  it 'enables NFS V2' do
    is_expected.to contain_augeas('RPCNFSDARGS="-V 2"').with(
      changes: 'set RPCNFSDARGS \'"-V 2"\'',
    )
  end
end

shared_examples 'daq common' do
  %w[
    /srv
    /srv/nfs
    /srv/nfs/dsl
    /srv/nfs/lsst-daq
    /srv/nfs/lsst-daq/daq-sdk
  ].each do |f|
    it do
      is_expected.to contain_file(f).with(
        ensure: 'directory',
        owner: 'root',
        group: 'root',
        mode: '0755',
      )
    end
  end

  it do
    is_expected.to contain_mount('/srv/nfs/lsst-daq/daq-sdk').with(
      device: '/opt/lsst/daq-sdk',
      fstype: 'none',
      options: 'defaults,bind',
    ).that_requires('File[/srv/nfs/lsst-daq/daq-sdk]')
  end

  it do
    is_expected.to contain_mount('/srv/nfs/lsst-daq/rpt-sdk').with(
      device: '/opt/lsst/rpt-sdk',
      fstype: 'none',
      options: 'defaults,bind',
    ).that_requires('File[/srv/nfs/lsst-daq/rpt-sdk]')
  end

  it do
    is_expected.to contain_mount('/srv/nfs/dsl').with(
      device: '/opt/lsst/rpt-sdk',
      fstype: 'none',
      options: 'defaults,bind',
    ).that_requires('File[/srv/nfs/dsl]')
  end
end

shared_examples 'debugutils' do
  it { is_expected.to contain_package('jq') }
end

shared_examples 'puppet_master' do
  it do
    is_expected.to contain_cron('webhook').with_command('/usr/bin/systemctl restart webhook > /dev/null 2>&1')
  end

  it do
    is_expected.to contain_cron('smee').with_command('/usr/bin/systemctl restart smee > /dev/null 2>&1')
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
  it { is_expected.to contain_foreman_proxy__plugin('dynflow') }
  it { is_expected.to contain_foreman__plugin('discovery') }
  it { is_expected.to contain_foreman__cli__plugin('foreman_discovery') }
  it { is_expected.to contain_foreman_proxy__plugin('discovery') }

  it { is_expected.to contain_class('foreman_proxy::plugin::dynflow') }

  it do
    is_expected.to contain_file('/var/lib/tftpboot/boot/udev_fact.zip').with(
      ensure: 'file',
      owner: 'foreman-proxy',
      group: 'foreman-proxy',
      mode: '0644',
      source: 'puppet:///modules/profile/foreman/udev_fact.zip',
    )
  end

  it { is_expected.to contain_package('ipmitool') }
end

shared_examples 'docker' do
  docker_version = '20.10.12'

  it do
    is_expected.to contain_class('docker').with(
      overlay2_override_kernel_check: true,
      package_source: 'docker-ce',
      socket_group: 70_014,
      socket_override: false,
      storage_driver: 'overlay2',
      version: docker_version,
    )
  end

  it { is_expected.to contain_class('docker::networks') }

  %w[
    docker-ce
    docker-ce-cli
    docker-ce-rootless-extras
  ].each do |pkg|
    it { is_expected.to contain_yum__versionlock(pkg).with_version(docker_version) }
  end

  it do
    is_expected.to contain_yum__versionlock('containerd.io').with(
      version: '1.4.12',
    )
  end

  it do
    is_expected.to contain_yum__versionlock('docker-scan-plugin').with(
      version: '0.12.0',
    )
  end
end

# 'spec_overrides' from sync.yml will appear below this line
