# @summary
#   Configure the host to use i2c
#
# @param packages
#  An array of packages to install
#
class profile::core::i2c (
  Optional[Array[String[1]]] $packages = undef,
) {
  if $packages {
    ensure_packages($packages)
  }

  # packages which do not exists in el7; mv to hiera when el7 is no longer supported
  if fact('os.family') == 'RedHat' and fact('os.release.major') == '9' {
    ensure_packages(['python3-i2c-tools'])
  }

  systemd::udev::rule { 'i2c.rules':
    rules => [
      'KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"',
    ],
  }

  unless defined(Group['i2c']) {
    group { 'i2c':
      ensure     => present,
      forcelocal => true,
      system     => true,
    }
  }

  kmod::load { 'i2c_dev': }

  if fact('cpuinfo.processor.Model') =~ /Raspberry Pi/ {
    pi::config::fragment { 'i2c':
      content => 'dtparam=i2c_arm=on',
    }
  }
}
