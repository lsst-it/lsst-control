# @summary
#   Install foreman_envsync gem
#
# @param version
#   Version of gem to install
#
class profile::core::foreman_envsync (
  String $version = '0.1.4',
) {
  include scl

  $pkgs = [
    'devtoolset-7',
    'rh-ruby25-ruby-devel',
  ]

  package { $pkgs:
    require => Class['scl']
  }

  $gem  = 'foreman_envsync'
  # need to avoid breaking foreman's ruby deps
  $opts = '--bindir /bin --ignore-dependencies --no-ri --no-rdoc'
  $scls = 'devtoolset-7 tfm'

  $scl_enable = "/bin/scl enable ${scls}"
  $install_cmd = "gem install --version ${version} ${opts} ${gem}"

  exec { $install_cmd:
    command => "${scl_enable} -- ${install_cmd}",
    unless  => "${scl_enable} -- gem list -i -l --version ${version} ${gem}",
    require => Package[$pkgs],
  }
}
