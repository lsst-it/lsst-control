class profile::app::rke(
  String $version = '1.0.4',
) {
  include archive

  $install_path = '/bin'
  $cmd          = 'rke'
  $cmd_path     = "${install_path}/${cmd}"
  $uname        = 'linux'
  $arch         = 'amd64'
  $source       = "https://github.com/rancher/rke/releases/download/v${version}/rke_${uname}-${arch}"

  archive { $cmd_path:
    ensure => present,
    source => $source,
  }
  -> file { $cmd_path:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}
