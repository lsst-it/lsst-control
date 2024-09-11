# frozen_string_literal: true

require 'voxpupuli/test/spec_helper'
require 'iniparse'
include RspecPuppetFacts

# foreman, puppetserver and termini versions
FOREMAN_VERSION = '3.2.1'
PUPPETAGENT_VERSION = '7.27.0'
PUPPETSERVER_VERSION = '7.14.0'
TERMINI_VERSION = PUPPETSERVER_VERSION

# facterdb does not include puppetlabs/stdlib facts
add_stdlib_facts
# voxpupuli-test 5.4.1 does not include puppetlabs/stdlib package_provider fact
add_custom_fact :package_provider, 'yum', confine: 'centos-7-x86_64' # puppet/yum
add_custom_fact :package_provider, 'dnf', confine: 'almalinux-8-x86_64' # puppet/yum

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
def hiera_public_hierarchy
  hc = YAML.load_file(control_hiera_config, aliases: true)
  hc['hierarchy'].find { |h| h['name'] == 'public hiera' }['paths']
end

def hiera_all_files
  hiera_public_hierarchy.map { |l| hiera_files_in_layer(l) }.flatten
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
  hiera_public_hierarchy.grep(%r{role})
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
    default_facts.merge!(YAML.safe_load(File.read(f)))
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
  # stub out enc parameters which will show up as top level variables, if set.
  c.default_node_params = {
    role: nil,
    site: nil,
    cluster: nil,
    variant: nil,
    subvariant: nil,
  }
end

# Disable rspec-puppet coverage reporting which is hardwired as enabled here:
# https://github.com/voxpupuli/voxpupuli-test/blob/88c0ae0c635dee496ba361501d6afa79b9d886f2/lib/voxpupuli/test/spec_helper.rb#L21
# Note that this is violating the private api of `RSpec::Core::Configuration`.
RSpec.configuration.instance_variable_set(:@after_suite_hooks, [])

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

# wrapper around #override_facts from voxpupuli-test that generates lsst's
# default [networking] node facts.
def lsst_override_facts(base_facts, **overrides)
  override_facts(base_facts, **override_facts(gen_net_facts, **overrides))
end

# depends on node_params being set
def gen_net_facts
  if nodename(:host) =~ %r{\.lsst\.org$}
    fqdn = nodename(:host)
    hostname = fqdn.split('.').first
    domain = fqdn.split('.').drop(1).join('.')
  else
    hostname = node_params[:role]
    domain = "#{node_params[:site]}.lsst.org"
    fqdn = "#{hostname}.#{domain}"
  end

  {
    networking: {
      'hostname' => hostname,
      'domain' => domain,
      'fqdn' => fqdn,
    },
  }
end

shared_context 'with site.pp', :sitepp do
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

shared_examples 'common' do |os_facts:, site:, no_auth: false, chrony: true, node_exporter: true|
  include_examples 'bash_completion', os_facts: os_facts
  include_examples 'convenience'
  include_examples 'telegraf'
  include_examples 'rsyslog defaults', site: site

  unless no_auth
    # inspect config fragment instead of class params to ensure that %{uid} is not
    # being caught by hiera string interpolation
    include_examples 'krb5.conf content', %r{default_ccache_name = FILE:/tmp/krb5cc_%{uid}}

    include_examples 'krb5.conf.d files', os_facts: os_facts
    include_examples 'sssd services'

    it { is_expected.to contain_class('ssh').that_requires('Class[ipa]') }

    it do
      # XXX dev is using ls ipa servers
      next if site == 'dev'

      is_expected.to contain_class('mit_krb5').with(
        default_realm: 'LSST.CLOUD',
        dns_canonicalize_hostname: true,
        dns_lookup_kdc: false,
        dns_lookup_realm: false,
        forwardable: true,
        krb5_conf_d_purge: true,
        rdns: false,
        ticket_lifetime: '24h',
        udp_preference_limit: 0,
        includedir: [
          '/etc/krb5.conf.d/',
          '/var/lib/sss/pubconf/krb5.include.d/',
        ],
        realms: {
          'LSST.CLOUD' => {
            'kdc' => "ipa1.#{site}.lsst.org:88",
            'master_kdc' => "ipa1.#{site}.lsst.org:88",
            'admin_server' => "ipa1.#{site}.lsst.org:749",
            'kpasswd_server' => "ipa1.#{site}.lsst.org:464",
            'default_domain' => 'lsst.cloud',
            'pkinit_anchors' => 'FILE:/var/lib/ipa-client/pki/kdc-ca-bundle.pem',
            'pkinit_pool' => 'FILE:/var/lib/ipa-client/pki/ca-bundle.pem',
          },
        },
        domain_realms: {
          'LSST.CLOUD' => {
            'domains' => [
              '.lsst.cloud',
              'lsst.cloud',
              facts[:networking]['fqdn'],
              ".#{facts[:networking]['domain']}",
              facts[:networking]['domain'],
            ],
          },
        },
      ).that_requires('Class[ipa]')
    end

    if os_facts[:os]['release']['major'] == '7'
      it do
        is_expected.to contain_file('/etc/sssd/sssd.conf').with_content(<<~SSSD)
          #
          # This file managed by Puppet - DO NOT EDIT
          #

          [sssd]
          config_file_version=2
          domains=lsst.cloud
          services=nss, pam, ssh, sudo

          [domain/lsst.cloud]
          access_provider=ipa
          auth_provider=ipa
          cache_credentials=true
          chpass_provider=ipa
          dns_discovery_domain=#{site}._locations.lsst.cloud
          id_provider=ipa
          ipa_domain=lsst.cloud
          ipa_hostname=#{facts[:networking]['fqdn']}
          ipa_server=_srv_, ipa1.#{(site == 'dev') ? 'ls' : site}.lsst.org
          krb5_store_password_if_offline=true
          ldap_tls_cacert=/etc/ipa/ca.crt

          [nss]
          homedir_substring=/home

          [pam]
          pam_response_filter=ENV:KRB5CCNAME:sudo-i
        SSSD
      end
    else
      it do
        is_expected.to contain_file('/etc/sssd/sssd.conf').with_content(<<~SSSD)
          #
          # This file managed by Puppet - DO NOT EDIT
          #

          [sssd]
          config_file_version=2
          domains=lsst.cloud
          services=nss, pam, ssh, sudo

          [domain/lsst.cloud]
          access_provider=ipa
          auth_provider=ipa
          cache_credentials=true
          chpass_provider=ipa
          dns_discovery_domain=#{site}._locations.lsst.cloud
          id_provider=ipa
          ipa_domain=lsst.cloud
          ipa_hostname=#{facts[:networking]['fqdn']}
          ipa_server=_srv_, ipa1.#{(site == 'dev') ? 'ls' : site}.lsst.org
          krb5_store_password_if_offline=true
          ldap_tls_cacert=/etc/ipa/ca.crt

          [nss]
          homedir_substring=/home
        SSSD
      end
    end
  end

  if node_exporter
    include_examples 'node_exporter'
  else
    include_examples 'no node_exporter'
  end

  if os_facts[:os]['family'] == 'RedHat'
    if os_facts[:os]['release']['major'] == '7' && os_facts[:os]['architecture'] == 'aarch64'
      # 7.24.0 is the last version of puppet-agent to support aarch64 on RHEL 7
      # see: http://yum.puppet.com/puppet7/el/7/aarch64/
      let(:puppetagent_version) { '7.24.0' }
    else
      let(:puppetagent_version) { PUPPETAGENT_VERSION }
    end

    it do
      is_expected.to contain_yum__versionlock('puppet-agent')
        .with_version(puppetagent_version)
    end

    it do
      is_expected.to contain_package('puppet-agent')
        .with_ensure(puppetagent_version)
    end

    it { is_expected.to contain_class('epel') }
    it { is_expected.to contain_class('yum::plugin::versionlock').with_clean(true) }
    it { is_expected.to contain_class('yum').with_manage_os_default_repos(true) }
    it { is_expected.to contain_resources('yumrepo').with_purge(true) }
    it { is_expected.to contain_class('profile::core::yum') }
    it { is_expected.to contain_file('/etc/rc.d/rc.local').with_ensure('absent') }
    it { is_expected.to contain_file('/etc/rc.local').with_ensure('absent') }

    # extras repo should be enabled. puppet/yum disables it by default on EL7.
    it do
      expect(catalogue.resource('class', 'yum')[:repos]['extras']).to include('enabled' => true)
    end

    if os_facts[:os]['release']['major'] == '7'
      it { is_expected.not_to contain_package('NetworkManager-initscripts-updown') }
      it { is_expected.to contain_class('yum').with_managed_repos(['extras']) }
      it { is_expected.to contain_class('lldpd').with_manage_repo(true) }

      it { is_expected.not_to contain_class('nm') }

      if os_facts[:os]['architecture'] == 'x86_64'
        it { is_expected.to contain_class('scl') }
      else
        it { is_expected.not_to contain_class('scl') }
      end
    else # every EL version except 7
      it { is_expected.not_to contain_class('yum').with_managed_repos(['extras']) }
      it { is_expected.not_to contain_class('scl') }

      it do
        is_expected.to contain_class('nm').with(
          conf: {
            'main' => {
              'dns' => 'none',
            },
            'logging' => {},
          },
        )
      end
    end

    if os_facts[:os]['release']['major'] == '8'
      it { is_expected.to contain_class('lldpd').with_manage_repo(true) }

      it { is_expected.to contain_class('nm') }
      it { is_expected.to contain_package('NetworkManager-initscripts-updown') }
    end

    if os_facts[:os]['release']['major'] == '9'
      it { is_expected.to contain_class('lldpd').with_manage_repo(false) }

      it { is_expected.to contain_class('nm') }
      it { is_expected.to contain_package('NetworkManager-initscripts-updown') }
      it { is_expected.to contain_class('yum').with_managed_repos(['crb']) }

      it do
        expect(catalogue.resource('class', 'yum')[:repos]['crb']).to include('enabled' => true)
      end
    end
  else # not osfamily RedHat
    it { is_expected.not_to contain_class('epel') }
    it { is_expected.not_to contain_class('yum::plugin::versionlock') }
    it { is_expected.not_to contain_yum__versionlock('puppet-agent') }
    it { is_expected.not_to contain_class('yum') }
    it { is_expected.not_to contain_resources('yumrepo').with_purge(true) }
  end

  if chrony
    it do
      is_expected.to contain_class('chrony').with(
        cmdport: 0,
        leapsecmode: 'system',
        leapsectz: 'right/UTC',
        local_stratum: false,
        logchange: 0.005,
        port: 0,
      )
    end
  end

  admin_users = %w[
    jhoblitt_b
    cbarria_b
    csilva_b
    dtapia_b
    gseriche_b
  ]

  (admin_users + ['root']).each do |user|
    it do
      is_expected.to contain_ssh__server__match_block(user).with(
        type: 'user',
        options: {
          'AuthorizedKeysFile' => '.ssh/authorized_keys',
        },
      )
    end
  end

  admin_users.each do |user|
    it do
      is_expected.to contain_user(user).with(
        ensure: 'present',
        groups: ['wheel_b'],
        purge_ssh_keys: true,
      )
    end
  end

  %w[
    lssttech
    sysadmin
    athebo
    athebo_b
    hreinking_b
  ].each do |user|
    it { is_expected.to contain_user(user).with_ensure('absent') }
  end

  it { is_expected.to contain_class('systemd').with_manage_udevd(true) }
  it { is_expected.to contain_class('sudo').with_purge(true) }

  # All host spec are expected to set the role & site node params. The other
  # node params will vary per host spec.
  it do
    is_expected.to contain_class('profile::core::node_info').with(
      role: node_params[:role],
      site: node_params[:site],
      cluster: node_params[:cluster],
      variant: node_params[:variant],
      subvariant: node_params[:subvariant],
    )
  end
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
      .with_value('bbr')
  end

  it do
    is_expected.to contain_sysctl__value('net.ipv4.tcp_slow_start_after_idle')
      .with_value(0)
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

shared_examples 'nfsv2 enabled' do |os_facts:|
  if os_facts[:os]['release']['major'] == '7'
    it 'enables NFS V2 exports via /etc/sysconfig/nfs' do
      is_expected.to contain_augeas('enable nfs v2 exports').with(
        context: '/files/etc/sysconfig/nfs',
        changes: 'set RPCNFSDARGS \'"-V 2"\'',
      )
    end
  else
    it 'enables NFS V2 exports via /etc/nfs.conf' do
      is_expected.to contain_augeas('enable nfs v2 exports').with(
        context: '/files/etc/nfs.conf/nfsd',
        lens: 'Puppet.lns',
        incl: '/etc/nfs.conf',
        changes: [
          'set vers2 yes',
          'set UDP yes',
        ],
      )
    end
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

shared_examples 'bash_completion' do |os_facts:|
  if os_facts[:os]['family'] == 'RedHat'
    it { is_expected.to contain_package('bash-completion') }

    if os_facts[:os]['release']['major'] == '7'
      it { is_expected.to contain_package('bash-completion-extras') }
    else
      it { is_expected.not_to contain_package('bash-completion-extras') }
    end
  else
    it { is_expected.not_to contain_package('bash-completion') }
  end
end

shared_examples 'convenience' do
  %w[
    ack
    diffstat
    fpart
    git
    jq
    neovim
    parallel
    rsync
    screen
    tree
    vim
  ].each do |pkg|
    it { is_expected.to contain_package(pkg) }
  end
end

shared_examples 'dco' do
  it do
    is_expected.to contain_vcsrepo('/home/dco/docker-compose-ops').with(
      ensure: 'present',
      provider: 'git',
      source: 'https://github.com/lsst-it/docker-compose-ops.git',
      keep_local_changes: true,
      user: 'dco',
      owner: 'dco',
      group: 'dco',
    )
  end

  it do
    is_expected.to contain_vcsrepo('/home/dco/ts_ddsconfig').with(
      ensure: 'present',
      provider: 'git',
      source: 'https://github.com/lsst-ts/ts_ddsconfig.git',
      keep_local_changes: true,
      user: 'dco',
      owner: 'dco',
      group: 'dco',
    )
  end

  it do
    is_expected.to contain_vcsrepo('/home/dco/docker-compose-admin').with(
      ensure: 'present',
      provider: 'git',
      source: 'https://github.com/lsst-ts/docker-compose-admin.git',
      keep_local_changes: true,
      user: 'dco',
      owner: 'dco',
      group: 'dco',
    )
  end
end

shared_context 'with nm interface' do
  let(:nm_keyfile_raw) do
    int = catalogue.resource('file', "/etc/NetworkManager/system-connections/#{interface}.nmconnection")
    if int.nil?
      raise "nm::connection[#{interface}] not found in catalogue"
    end

    int[:content]
  end

  let(:nm_keyfile) do
    IniParse.parse(nm_keyfile_raw)
  end
end

shared_examples 'nm named interface' do
  it { expect(nm_keyfile['connection']['id']).to eq(interface) }
  it { expect(nm_keyfile['connection']['interface-name']).to eq(interface) }
end

shared_examples 'nm enabled interface' do
  it_behaves_like 'nm named interface'
  it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
end

shared_examples 'nm disabled interface' do
  it_behaves_like 'nm named interface'
  it_behaves_like 'nm no-ip interface'
  it_behaves_like 'nm ethernet interface'
  it { expect(nm_keyfile['connection']['autoconnect']).to be false }
end

shared_examples 'nm ethernet interface' do
  it { expect(nm_keyfile['connection']['type']).to eq('ethernet') }
  it { expect(nm_keyfile_raw).to match(%r{^\[ethernet\]$}) }
end

shared_examples 'nm dhcp interface' do
  it { expect(nm_keyfile['ipv4']['method']).to eq('auto') }
  it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
end

shared_examples 'nm bridge interface' do
  it { expect(nm_keyfile['connection']['type']).to eq('bridge') }
  it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
  it { expect(nm_keyfile['bridge']['stp']).to be false }
  it { expect(nm_keyfile_raw).to match(%r{^\[ethernet\]$}) }
  it { expect(nm_keyfile_raw).to match(%r{^\[proxy\]$}) }
end

shared_examples 'nm bridge slave interface' do |master:|
  it { expect(nm_keyfile['connection']['master']).to eq(master) }
  it { expect(nm_keyfile['connection']['slave-type']).to eq('bridge') }
  it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
  it { expect(nm_keyfile_raw).to match(%r{^\[ethernet\]$}) }
  it { expect(nm_keyfile_raw).to match(%r{^\[bridge-port\]$}) }
  it { expect(nm_keyfile_raw).not_to match(%r{^\[ipv4\]$}) }
  it { expect(nm_keyfile_raw).not_to match(%r{^\[ipv6\]$}) }
end

shared_examples 'nm vlan interface' do |id:, parent:|
  it { expect(nm_keyfile['connection']['type']).to eq('vlan') }
  it { expect(nm_keyfile['vlan']['flags']).to eq(1) }
  it { expect(nm_keyfile['vlan']['id']).to eq(id) }
  it { expect(nm_keyfile['vlan']['parent']).to eq(parent) }
end

shared_examples 'nm bond interface' do
  it { expect(nm_keyfile['connection']['type']).to eq('bond') }
  it { expect(nm_keyfile['bond']['miimon']).to eq(100) }
  it { expect(nm_keyfile['bond']['mode']).to eq('802.3ad') }
  it { expect(nm_keyfile_raw).to match(%r{^\[ethernet\]$}) }
  it { expect(nm_keyfile_raw).to match(%r{^\[proxy\]$}) }
end

shared_examples 'nm bond slave interface' do |master:|
  it { expect(nm_keyfile['connection']['master']).to eq(master) }
  it { expect(nm_keyfile['connection']['slave-type']).to eq('bond') }
  it { expect(nm_keyfile_raw).to match(%r{^\[ethernet\]$}) }
  it { expect(nm_keyfile_raw).not_to match(%r{^\[ipv4\]$}) }
  it { expect(nm_keyfile_raw).not_to match(%r{^\[ipv6\]$}) }
end

shared_examples 'nm no-ip interface' do
  it { expect(nm_keyfile['ipv4']['method']).to eq('disabled') }
  it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
end

shared_examples 'nm no default route' do
  it { expect(nm_keyfile['ipv4']['never-default']).to be true }
end

shared_examples 'nm manual interface' do
  it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
  it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
end

shared_examples 'ccs alerts' do
  it do
    is_expected.to contain_file('/etc/ccs/systemd-email').with(
      content: %r{^EMAIL=#{alert_email}},
    )
  end

  it do
    is_expected.to contain_file('/etc/monit.d/alert').with(
      content: %r{^set alert #{alert_email}},
    )
  end
end

shared_examples 'generic perfsonar' do
  it do
    is_expected.to contain_letsencrypt__certonly(facts[:networking]['fqdn']).with(
      plugin: 'dns-route53',
      manage_cron: true,
    )
  end

  it do
    is_expected.to contain_yumrepo('perfSONAR').with(
      descr: 'perfSONAR RPM Repository - software.internet2.edu - main',
      baseurl: "http://software.internet2.edu/rpms/el#{facts[:os]['release']['major']}/x86_64/#{perfsonar_version}/",
      enabled: '1',
      protect: '0',
      gpgkey: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-perfSONAR',
      gpgcheck: '1',
      mirrorlist: 'absent',
    )
  end

  it do
    is_expected.to contain_class('perfsonar').with(
      manage_apache: true,
      remove_root_prompt: true,
      manage_epel: false,
      manage_repo: false,
      ssl_cert: "#{le_root}/cert.pem",
      ssl_chain_file: "#{le_root}/fullchain.pem",
      ssl_key: "#{le_root}/privkey.pem",
    )
                                             .that_requires('Yumrepo[perfSONAR]')
                                             .that_requires('Class[epel]')
                                             .that_requires("Letsencrypt::Certonly[#{facts[:networking]['fqdn']}]")
  end

  it do
    is_expected.to contain_service('yum-cron').with(
      ensure: 'stopped',
      enable: false,
    )
  end
end

shared_examples 'x2go packages' do |os_facts:|
  packages = if (os_facts[:os]['family'] == 'RedHat') && (os_facts[:os]['release']['major'] == '7')
               %w[
                 x2goagent
                 x2goclient
                 x2godesktopsharing
                 x2goserver
                 x2goserver-common
                 x2goserver-xsession
               ]
             else
               %w[
                 x2goagent
                 x2goclient
                 x2goserver
                 x2goserver-common
                 x2goserver-xsession
               ]
             end

  packages.each do |pkg|
    it { is_expected.to contain_package(pkg) }
  end

  it do
    is_expected.to contain_file('/etc/sudoers.d/x2goserver').with(
      ensure: 'file',
      owner: 'root',
      group: 'root',
      mode: '0440',
    ).that_requires('Package[x2goserver]')
  end
end

shared_examples 'ccs common' do
  it { is_expected.to contain_package('time') }
end

shared_examples 'daq nfs exports' do
  it do
    is_expected.to contain_class('nfs').with(
      server_enabled: true,
      client_enabled: true,
      nfs_v4_client: false,
    )
  end

  it { is_expected.to contain_class('nfs::server').with_nfs_v4(false) }
  it { is_expected.to contain_nfs__server__export('/srv/nfs/dsl') }
  it { is_expected.to contain_nfs__server__export('/srv/nfs/lsst-daq') }

  it do
    is_expected.to contain_nfs__client__mount('/net/self/dsl').with(
      share: '/srv/nfs/dsl',
      server: facts[:networking]['fqdn'],
      atboot: true,
    )
  end

  it do
    is_expected.to contain_nfs__client__mount('/net/self/lsst-daq').with(
      share: '/srv/nfs/lsst-daq',
      server: facts[:networking]['fqdn'],
      atboot: true,
    )
  end
end

shared_examples 'krb5.conf.d files' do |os_facts:|
  to = if (os_facts[:os]['family'] == 'RedHat') && (os_facts[:os]['release']['major'] == '7')
         'not_to'
       else
         'to'
       end

  it do
    is_expected.send(to, contain_file('/etc/krb5.conf.d/crypto-policies').with(
                           ensure: 'link',
                           owner: 'root',
                           group: 'root',
                           target: '/etc/crypto-policies/back-ends/krb5.config',
                         ))
  end

  it do
    is_expected.send(to, contain_file('/etc/krb5.conf.d/freeipa').with(
                           ensure: 'file',
                           owner: 'root',
                           group: 'root',
                           content: <<~CONTENT,
        [libdefaults]
            spake_preauth_groups = edwards25519
                           CONTENT
                         ))
  end
end

shared_examples 'baremetal' do |bmc: nil|
  include_examples 'ipmi'
  it do
    if node_params[:role] == 'hypervisor'
      is_expected.to contain_class('tuned').with_active_profile('virtual-host')
    end
  end

  if bmc.nil?
    it { is_expected.to contain_ipmi__network('lan1').with_type('dhcp') }
  else
    bmc.each do |intf, conf|
      it { is_expected.to contain_ipmi__network(intf).with(conf) }
    end
  end

  it { is_expected.to contain_class('powertop') }
end

shared_examples 'baremetal no bmc' do
  it { is_expected.not_to contain_class('ipmi') }
end

shared_examples 'vm' do
  it { is_expected.not_to contain_class('ipmi') }
  it { is_expected.to contain_class('tuned').with_active_profile('virtual-guest') }
  it { is_expected.not_to contain_class('powertop') }
end

shared_examples 'ipmi' do
  it { is_expected.to contain_class('ipmi') }
end

shared_examples 'fog_hack' do
  it { is_expected.to contain_package('libvirt-devel') }

  it do
    is_expected.to contain_archive('fog-libvirt-0.11.0.gem').with(
      ensure: 'present',
      path: '/tmp/fog-libvirt-0.11.0.gem',
      source: 'https://github.com/lsst-it/fog-libvirt/releases/download/v0.11.0/fog-libvirt-0.11.0.gem',
    ).that_notifies('Exec[install-fog-libvirt.0.11.0.gem]')
  end

  it do
    is_expected.to contain_exec('install-fog-libvirt.0.11.0.gem').with(
      command: '/usr/bin/scl enable rh-ruby27 tfm -- gem install /tmp/fog-libvirt-0.11.0.gem',
      path: '/usr/bin:/bin',
      refreshonly: true,
    ).that_requires('Package[libvirt-devel]')
  end
end

Dir['./spec/support/spec/**/*.rb'].sort.each { |f| require f }

# 'spec_overrides' from sync.yml will appear below this line
