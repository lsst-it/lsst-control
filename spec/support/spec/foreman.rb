# frozen_string_literal: true

shared_examples 'foreman' do
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
      source: 'puppet:///modules/profile/foreman/udev_fact.zip'
    )
  end

  it { is_expected.to contain_package('ipmitool') }
  it { is_expected.to contain_package('hiera-eyaml').with_provider('puppetserver_gem') }

  it do
    is_expected.to contain_file('/etc/puppetlabs/puppet/eyaml').with(
      ensure: 'directory',
      owner: 'puppet',
      group: 'puppet',
      mode: '0500'
    ).that_requires('Class[puppet]')
  end
end

shared_examples 'generic foreman' do
  include_examples 'debugutils'
  include_examples 'docker'
  include_examples 'fog_hack'
  include_examples 'foreman'

  it do
    is_expected.to contain_class('foreman').with(
      version: FOREMAN_VERSION
    )
  end

  it do
    is_expected.to contain_class('foreman::repo').with(
      repo: '3.2'
    )
  end

  it do
    is_expected.to contain_class('foreman_proxy').with(
      bmc_default_provider: 'ipmitool',
      bmc: true
    )
  end

  %w[
    foreman
    foreman-cli
    foreman-debug
    foreman-dynflow-sidekiq
    foreman-installer
    foreman-libvirt
    foreman-postgresql
    foreman-proxy
    foreman-service
    foreman-vmware
  ].each do |pkg|
    it { is_expected.to contain_yum__versionlock(pkg).with_version(FOREMAN_VERSION) }
  end

  it do
    is_expected.to contain_yum__versionlock('puppetserver').with(
      version: PUPPETSERVER_VERSION
    )
  end

  it do
    is_expected.to contain_yum__versionlock('puppetdb-termini').with(
      version: TERMINI_VERSION
    )
  end

  it do
    is_expected.to contain_class('foreman_proxy::plugin::discovery').with(
      image_name: 'fdi-image-4.99.99-6224850.tar',
      install_images: true,
      source_url: 'https://github.com/lsst-it/foreman-discovery-image/releases/download/lsst-4.99.99/'
    )
  end

  it { is_expected.to contain_class('puppetdb::globals').with_version(TERMINI_VERSION) }

  it do
    is_expected.to contain_class('puppet').with(
      server_puppetserver_version: PUPPETSERVER_VERSION,
      server_reports: 'foreman,puppetdb',
      server_storeconfigs: true,
      server_version: PUPPETSERVER_VERSION
    )
  end

  it 'has global ProxyCommand knocked out with --' do
    expect(catalogue.resource('class', 'ssh')[:client_options]).to include(
      'ProxyCommand' => ''
    )
  end

  it 'has foreman & foreman-proxy user exempt from ProxyCommand' do
    expect(catalogue.resource('class', 'ssh')[:client_match_block]).to include(
      'foreman,foreman-proxy' => {
        'type' => '!localuser',
        'options' => {
          'ProxyCommand' => '/usr/bin/sss_ssh_knownhostsproxy -p %p %h',
        },
      }
    )
  end

  it 'disables StrictHostKeyChecking for github.com' do
    expect(catalogue.resource('class', 'ssh')[:client_match_block]).to include(
      'github.com' => {
        'type' => 'host',
        'options' => {
          'StrictHostKeyChecking' => 'no',
        },
      }
    )
  end

  it 'disables StrictHostKeyChecking for foreman user' do
    expect(catalogue.resource('class', 'ssh')[:client_match_block]).to include(
      'foreman' => {
        'type' => 'localuser',
        'options' => {
          'StrictHostKeyChecking' => 'no',
        },
      }
    )
  end

  {
    'bootloader-append': 'nofb',
    'disable-firewall': true,
    'enable-epel': true,
    'enable-puppetlabs-puppet6-repo': false,
    'enable-official-puppet7-repo': true,
    fips_enabled: false,
    host_registration_insights: false,
    host_registration_remote_execution: true,
    package_upgrade: true,
    role: 'generic',
    'selinux-mode': 'disabled',
  }.each do |k, v|
    it { is_expected.to contain_foreman_global_parameter(k).with_value(v) }
  end

  %w[
    org
    restic_password
  ].each do |v|
    it { is_expected.to contain_foreman_global_parameter(v).with_ensure('absent') }
  end

  it { is_expected.to contain_foreman_global_parameter('site').with_value(site) }

  it do
    is_expected.to contain_foreman_global_parameter('ntp-server')
      .with_value(ntpservers.join(','))
  end

  {
    bmc_credentials_accessible: false,
    default_pxe_item_global: 'discovery',
    destroy_vm_on_host_delete: true,
    host_details_ui: false,
    ignore_puppet_facts_for_provisioning: true,
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

  it { is_expected.to contain_foreman_hostgroup(site) }

  it do
    is_expected.to contain_class('foreman_envsync').with_image_tag('1.5.1')
  end

  it do
    is_expected.to contain_class('r10k').with_postrun(
      [
        'systemd-cat',
        '-t',
        'foreman_envsync',
        '/bin/foreman_envsync',
        '--verbose',
      ]
    )
  end

  it do
    is_expected.to contain_class('r10k').with_sources(
      'control' => {
        'remote' => 'https://github.com/lsst-it/lsst-control',
        'basedir' => '/etc/puppetlabs/code/environments',
        'invalid_branches' => 'correct',
        'ignore_branch_prefixes' => ignore_branch_prefixes,
      },
      'lsst_hiera_private' => {
        'remote' => 'git@github.com:lsst-it/lsst-puppet-hiera-private.git',
        'basedir' => '/etc/puppetlabs/code/hieradata/private',
        'invalid_branches' => 'correct',
        'ignore_branch_prefixes' => ignore_branch_prefixes,
      }
    )
  end

  it { is_expected.to contain_package('oauth').with_provider('puppet_gem') }

  it do
    is_expected.to contain_class('smee').with(
      url: smee_url,
      path: '/payload',
      port: 8088
    )
  end

  it do
    is_expected.to contain_yumrepo('pc_repo').with(
      baseurl: "http://yum.puppet.com/puppet7/el/#{facts[:os]['release']['major']}/x86_64"
    )
  end
end
