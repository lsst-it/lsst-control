# @summary This creates a dummy interface naming lhnrouting
#
# Creates a dummy interface named `lhnrouting`. This is to intended to be used
# as a kludge on EL7 to have a non-NM controlled interface that uses the
# standard route-<foo> and rule-<foo> files. On EL7, NM does not support
# rule-<foo> files at all.
#
# Inspired by https://forums.centos.org/viewtopic.php?t=53233
#
class profile::core::lhnrouting {
  # EL7 only
  if fact('os.family') == 'RedHat' and fact('os.release.major') == '7' {
    kmod::load { 'dummy': }
    kmod::install { 'dummy':
      command => '"/sbin/modprobe --ignore-install dummy; /sbin/ip link set name lhnrouting dev dummy0"',
    }
  }
}
