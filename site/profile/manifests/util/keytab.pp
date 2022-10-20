# @summary
#  Install a keytab for a user and manage an up-to-date TGT.
#
# @param name
#   Name of the user
#
# @param uid
#   UID of the user
#
# @param keytab_base64
#   base64 encoded krb5 keytab for the user
#
define profile::util::keytab (
  Integer $uid,
  Sensitive[String[1]] $keytab_base64,
) {
  $keytab_dir = '/var/lib/keytab'
  $keytab_path = "${keytab_dir}/${name}"
  $home_path = "/home/${name}"
  $old_keytab_path = "${home_path}/.keytab"

  # delete old keytab path in user's home dir
  file { $old_keytab_path:
    ensure => absent,
  }

  ensure_resource('file', $keytab_dir, {
      'ensure' => 'directory',
      owner    => 'root',
      group    => 'root',
      mode     => '0700',
      purge    => true,
      recurse  => true,
  })
  file { $keytab_path:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0400',
    show_diff => false, # do not print keytab in logs
    content   => base64('decode', $keytab_base64.unwrap),
  }

  cron { 'k5start_root':
    command => "/usr/bin/k5start -f ${keytab_path} -U -o ${uid} -k /tmp/krb5cc_${uid} -H 60 -F > /dev/null 2>&1",
    user    => 'root',
    minute  => '*/1',
    require => File[$keytab_path],
  }
}
