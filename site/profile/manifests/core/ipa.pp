# @summary
#   Manages ipa client configuration -- functionality not provided by easy_ipa.
#   XXX should be added to easy_ipa and upstream?
#
# @param default
#   Set values in `/etc/ipa/default.conf`.
#
class profile::core::ipa (
  Optional[Hash] $default = undef,
) {
  require easy_ipa

  $param_defaults = {
    'path'  => '/etc/ipa/default.conf',
    require => Class[easy_ipa],
  }

  if $default {
    inifile::create_ini_settings($default, $param_defaults)
  }
}
