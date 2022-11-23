# @summary
#   Manage NetworkManager
#
# @param connections
#   Hash of profile::nm::connection resources to create
#
class profile::nm (
  Optional[Hash[String, Hash]] $connections = undef,
) {
  $conf_dir= '/etc/NetworkManager/conf.d'
  $conn_dir = '/etc/NetworkManager/system-connections'

  # remove ifcfg-* files to prevent conflicts between ifcfg- and .nmconnection
  file { '/etc/sysconfig/network-scripts':
    ensure  => 'directory',
    purge   => true,
    recurse => true,
    force   => true,
  }

  # remove any conflicting nm drop-in config files
  # XXX NetworkManager.conf needs to be handled
  file { $conf_dir:
    ensure  => 'directory',
    purge   => true,
    recurse => true,
    force   => true,
  }

  file { "${conf_dir}/ignore-unknown-interfaces.conf":
    ensure  => 'file',
    mode    => '0644',
    # lint:ignore:strict_indent
    content => @("CONF"),
      [main]
      # do not create connections for unmanaged interfaces
      no-auto-default=*
      | CONF
    # lint:endignore
  }

  file { "${conf_dir}/resolv_conf.conf":
    ensure  => 'file',
    mode    => '0644',
    # lint:ignore:strict_indent
    content => @("CONF"),
      [main]
      # do not write to /etc/resolv.conf
      dns=none
      | CONF
    # lint:endignore
  }

  # remove unmanaged .nmconnection files
  file { $conn_dir:
    ensure  => 'directory',
    purge   => true,
    recurse => true,
    force   => true,
  }

  if $connections {
    ensure_resources('profile::nm::connection', $connections)
  }

  exec { 'nmcli conn reload':
    command     => '/bin/nmcli conn reload',
    refreshonly => true,
  }
}
