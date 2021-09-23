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
  String  $keytab_base64,
) {
  $home_path = "/home/${name}"
  $keytab_path = "${home_path}/.keytab"

  ensure_resource('file', $home_path, {
      'ensure' => 'directory',
      owner    => $name,
      group    => $name,
      mode     => '0700',
  })
  file { $keytab_path:
    ensure  => file,
    owner   => $name,
    group   => $name,
    mode    => '0400',
    content => base64('decode', $keytab_base64),
  }

  cron { 'k5start_root':
    command => "/usr/bin/k5start -f ${keytab_path} -U -o ${uid} -k /tmp/krb5cc_${uid} -H 60 > /dev/null 2>&1",
    user    => 'root',
    minute  => '*/1',
    require => File[$keytab_path],
  }
}
