class profile::app::helm (
  String $version = '3.0.3',
) {
  include archive

  $install_path = '/bin'
  $cmd          = 'helm'
  $cmd_path     = "${install_path}/${cmd}"
  $uname        = 'linux'
  $arch         = 'amd64'
  $base_url     = 'https://get.helm.sh'
  $archive_file = "helm-v${version}-${uname}-${arch}.tar.gz"
  $source       = "${base_url}/${archive_file}"

  archive { $archive_file:
    ensure          => present,
    path            => "/tmp/${archive_file}",
    source          => $source,
    extract         => true,
    extract_command => "tar -x -C ${install_path} --strip-components=1 -f %s ${uname}-${arch}/${cmd}",
    extract_path    => $install_path,
    creates         => $cmd_path,
    cleanup         => true,
  }
  -> file { $cmd_path:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}
