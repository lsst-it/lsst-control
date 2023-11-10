# @summary
#   Manages ipa client configuration -- functionality not provided by ipa mod.
#   XXX should be added to ipa mod?
#
# @param default
#   Set values in `/etc/ipa/default.conf`.
#
class profile::core::ipa (
  Optional[Hash] $default = undef,
) {
  require ipa

  $param_defaults = {
    'path'  => '/etc/ipa/default.conf',
    require => Class['ipa'],
  }

  if $default {
    inifile::create_ini_settings($default, $param_defaults)
  }
}
