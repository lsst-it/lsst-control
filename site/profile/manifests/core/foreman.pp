# @summary
#   Install foreman/puppetserver
#
# @param smee_url
#   URL to the smee topic to watch for webhook events.
#
# @param enable_puppetdb
#   Whether or not to enable puppetserver's puppetdb support.
#
# @param foreman_config
#   `foreman_config_entry` resources to create.  Note that these parameters are called
#   "Settings" in the foreman UI.
#
# @param foreman_hostgroup
#   `foreman_hostgroup` resources to create.
#
# @param foreman_global_parameter
#   `foreman_global_parameter` resources to create.
#
# @param manage_smee
#   Make smee installation opt-out
#
class profile::core::foreman (
  Optional[Stdlib::HTTPSUrl] $smee_url = undef,
  Boolean $enable_puppetdb = false,
  Optional[Hash[String, Hash]] $foreman_config = undef,
  Optional[Hash[String, Hash]] $foreman_hostgroup = undef,
  Optional[Hash[String, Hash]] $foreman_global_parameter = undef,
  Boolean $manage_smee = true,
) {
  include cron
  include foreman
  include foreman::cli
  include foreman::cli::discovery
  include foreman::cli::puppet
  include foreman::cli::remote_execution
  include foreman::cli::tasks
  include foreman::cli::templates
  include foreman::compute::libvirt
  include foreman::compute::vmware
  include foreman_envsync
  include foreman::plugin::column_view
  include foreman::plugin::discovery
  include foreman::plugin::puppet
  include foreman::plugin::remote_execution
  include foreman::plugin::tasks
  include foreman::plugin::templates
  include foreman_proxy
  include foreman_proxy::plugin::discovery
  include foreman_proxy::plugin::dns::route53
  include foreman_proxy::plugin::dynflow
  include foreman_proxy::plugin::remote_execution::script
  include foreman::repo
  include puppet
  include r10k
  include r10k::webhook
  include r10k::webhook::config

  if $enable_puppetdb {
    include puppet::server::puppetdb
  }

  Yum::Versionlock<| |> -> Class[foreman]

  if $foreman_config {
    ensure_resources('foreman_config_entry', $foreman_config)
  }

  if $foreman_hostgroup {
    ensure_resources('foreman_hostgroup', $foreman_hostgroup)
  }

  if $foreman_global_parameter {
    ensure_resources('foreman_global_parameter', $foreman_global_parameter)
  }

  # kickstart wants a comma-serparated list without spaces of ntp servers.
  # hiera interpolation always returns a string. A direct lookup() is the only option to
  # stay DRY.
  $ntpservers = lookup('dhcp::ntpservers', Array[String], undef, [])
  if $ntpservers {
    foreman_global_parameter { 'ntp-server':
      parameter_type => 'string',
      value          => join($ntpservers, ','),
    }
  }

  # smee has some startup problems due to too new (?) nodejs on EL8
  # https://gist.github.com/bastelfreak/6d0d3bc324633f04c5b1fc432e871192
  if $manage_smee {
    assert_type(Stdlib::HTTPSUrl, $smee_url)
    class { 'smee':
      url  => $smee_url,
      path => '/payload',
      port => 8088,
    }
    cron { 'smee':
      command => '/usr/bin/systemctl restart smee > /dev/null 2>&1',
      user    => 'root',
      hour    => 4,
      minute  => 42,
    }
  }

  # el7 systemd is too old to support periodic graceful restarts of a service unit.
  # Using cron seems slightly more obvious than creating a timer unit than triggers a one shot
  # service to restart the original service unit.
  cron { 'webhook':
    command => '/usr/bin/systemctl restart webhook > /dev/null 2>&1',
    user    => 'root',
    hour    => 4,
    minute  => 42,
  }

  package { 'hiera-eyaml':
    provider => 'puppetserver_gem',
  }

  # The foreman-selinux package is not managed by theforeman/foreman when selinux is disabled.  # This is to cleanup old installs.
  unless fact('os.selinux.enabled') {
    package { 'foreman-selinux':
      ensure => absent,
    }
  }

  # theforeman/foreman manages yum repos directly.  The foreman-release package
  # is not needed after bootstraping and can be removed.
  package { 'foreman-release':
    ensure  => absent,
    require => Class['foreman'],
  }

  if fact('os.family') == 'RedHat' and fact('os.release.major') == '7' {
    include scl
    Class['scl'] -> Class['foreman']
  }

  # XXX theforeman/puppet does not manage the yumrepo.  puppetlabs/puppet_agent
  # is hardwired to manage the puppet package and conflicts with
  # theforeman/puppet.  We should try to submit support to
  # puppetlabs/puppet_agent for managing only the yumrepo. The
  # puppet_agent::prepare class can not be directly included as
  # puppet_agent::osfamily::redhat uses puppet_agent::* variables.
  yumrepo { 'pc_repo':
    ensure   => 'present',
    baseurl  => "http://yum.puppet.com/puppet7/el/${fact('os.release.major')}/x86_64",
    descr    => 'Puppet Labs puppet7 Repository',
    enabled  => true,
    gpgcheck => '1',
    gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet\n  file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-20250406",
    before   => Class['puppet'],
  }

  file { '/var/lib/tftpboot/boot/udev_fact.zip':
    ensure => file,
    owner  => 'foreman-proxy',
    group  => 'foreman-proxy',
    mode   => '0644',
    source => "puppet:///modules/${module_name}/foreman/udev_fact.zip",
  }

  # for bmc management
  ensure_packages(['ipmitool'])

  package { 'oauth':
    ensure   => installed,
    provider => 'puppet_gem',
  }

  file { '/etc/puppetlabs/puppet/eyaml':
    ensure  => directory,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0500',
    require => Class['puppet'],  # ensure puppet user/group exist
  }
}
