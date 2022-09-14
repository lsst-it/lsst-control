# @summary
#   Generates profile::util::keytab resources
#
# @param keytab
#   Hash of keytab resources to create
#
class profile::core::keytab (
  Optional[Hash[String[1], Hash[String[1], NotUndef]]] $keytab = undef,
) {
  if $keytab {
    $keytab.each | String $name, Hash $conf | {
      profile::util::keytab { $name:
        * => $conf,
      }
    }
  }
}
