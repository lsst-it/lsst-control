class profile::app::macvlan(
  String $version = '0.8.5',
) {
  include archive

  $install_path = '/opt/cni/bin'
  $cmd          = 'macvlan'
  $cmd_path     = "${install_path}/${cmd}"
  $uname        = 'linux'
  $arch         = 'amd64'
  $base_url     = "https://github.com/containernetworking/plugins/releases/download/v${version}"
  $slug         = "cni-plugins-${uname}-${arch}-v${version}"
  $archive_file = "${slug}.tgz"
  $source       = "${base_url}/${archive_file}"

  $stat = {
    owner => 'root',
    group => 'root',
    mode  => '0755',
  }

  ensure_resources('file', {
    '/opt'         => $stat + { ensure => directory },
    '/opt/cni'     => $stat + { ensure => directory },
    '/opt/cni/bin' => $stat + { ensure => directory },
    $cmd_path      => $stat + { ensure => file, require => Archive[$archive_file] },
  })

  archive { $archive_file:
    ensure          => present,
    path            => "/tmp/${archive_file}",
    source          => $source,
    extract         => true,
    extract_command => "tar -x -C ${install_path} --strip-components=1 -f %s ./${cmd}",
    extract_path    => $install_path,
    creates         => $cmd_path,
    cleanup         => true,
    require         => File[$install_path],
  }
}
