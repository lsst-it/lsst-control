# @summary
#   Install ccs cantaloupe image server
#
# @param directory
#   String specifying directory to install to
# @param data_directory
#   String specifying data directory
# @param user
#   String specifying installation user
# @param group
#   String specifying installation group
# @param version
#   String specifying version component of installation directory
# @param pkgurl
#   String specifying url to fetch binaries from
# @param pkgurl_user
#   String specifying username for pkgurl
# @param pkgurl_pass
#   String specifying password for pkgurl
#
class profile::ccs::cantaloupe (
  String $directory = '/home/ccs/cantaloupe',
  String $data_directory = '/data/cantaloupe',
  String $user  = 'ccs',
  String $group = 'ccs',
  String $version = '5.0',
  String $pkgurl = $profile::ccs::common::pkgurl,
  Variant[Sensitive[String[1]],String[1]] $pkgurl_user = $profile::ccs::common::pkgurl_user,
  Sensitive[String[1]] $pkgurl_pass = $profile::ccs::common::pkgurl_pass,
) {
  [$directory, $data_directory].each | String $dir | {
    file { $dir:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0755',
    }
  }

  $version_directory = "${directory}/cantaloupe-${version}"
  file { $version_directory:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0755',
    require => File[$directory],
  }

  ['images', 'cache'].each | String $dir | {
    $src = "${data_directory}/${dir}"
    file { $src:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0755',
      require => File[$data_directory],
    }
    file { "${version_directory}/${dir}":
      ensure => link,
      owner  => $user,
      group  => $group,
      target => $src,
    }
  }

  $fileprops = {
    'ensure' => file,
    'owner'  => $user,
    'group'  => $group,
  }

  $files = [
    { 'name' => 'delegates.rb', 'mode' => '0644' },
    { 'name' => 'mem-monitor' , 'mode' => '0755' },
  ]

  $files.each | Hash $f | {
    $file = $f['name']
    $mode = $f['mode']
    file { "${version_directory}/${file}":
      source => "puppet:///modules/${module_name}/ccs/cantaloupe/${file}",
      mode   => $mode,
      *      => $fileprops,
    }
  }

  $propfile = 'cantaloupe.properties'

  file { "${version_directory}/${propfile}":
    mode    => '0644',
    content => epp("${module_name}/ccs/cantaloupe/${propfile}.epp", {
      cache  => "${version_directory}/cache",
      images => "${version_directory}/images",
    }),
    *       => $fileprops,
  }

  $jarfile = 'cantaloupe-5.0.4.jar'

  $jartmp = "/var/tmp/${jarfile}"

  archive { $jartmp:
    ensure   => present,
    source   => "${pkgurl}/${jarfile}",
    username => $pkgurl_user.unwrap,
    password => $pkgurl_pass.unwrap,
  }

  file { "${version_directory}/${jarfile}":
    mode   => '0644',
    source => $jartmp,
    *      => $fileprops,
  }

  $epp_vars = {
    desc    => 'Cantaloupe service',
    user    => $user,
    group   => $group,
    cmd     => "/usr/bin/java -Djruby.native.enabled=false -Dcantaloupe.config=${propfile} -XX:NativeMemoryTracking=summary -Dorg.lsst.fits.imageio.bufferedImageCacheSize=1000 -Xmx64g -jar ${jarfile}",
    workdir => $version_directory,
  }

  systemd::unit_file { 'cantaloupe.service':
    content => epp("${module_name}/ccs/service.epp", $epp_vars),
  }
  -> service { 'cantaloupe':
    enable => true,
  }

  cron::job { 'cantaloupe_mem_monitor':
    minute      => '*',
    hour        => '*',
    date        => '*',
    month       => '*',
    weekday     => '*',
    user        => $user,
    command     => "cd ${version_directory} && ./mem-monitor",
    environment => ['PATH="/bin"'],
    description => 'Check cantaloupe memory usage',
  }
}
