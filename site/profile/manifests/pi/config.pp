# @summary
#   Manages `/boot/config.txt`
#
# @param fragments
#  A hash of profile::pi::config::fragments to be concatenated into
#  `/boot/config.txt`.
#
# @param reboot
#   Whether or not to force a reboot when `/boot/config.txt` changes.
#
class profile::pi::config (
  Hash[String[1], Hash] $fragments = {},
  Boolean $reboot = true,
) {
  concat { '/boot/config.txt':
    ensure => present,
    mode   => '0755',  # this is the default, +x seems odd
  }

  $fragments.each | String $name, Hash $conf | {
    profile::pi::config::fragment { $name:
      * => $conf,
    }
  }

  if ($reboot) {
    reboot { '/boot/config.txt':
      apply   => finished,
      message => 'Rebooting to apply /boot/config.txt changes',
      when    => refreshed,
    }
  }
}
