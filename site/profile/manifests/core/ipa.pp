# @summary
#   Manages ipa client configuration -- functionality not provided by easy_ipa.
#   XXX should be added to easy_ipa and upstream?
#
# @param default
#   Set values in `/etc/ipa/default.conf`.
#
class profile::core::ipa(
  Hash $default,
) {
  inifile::create_ini_settings($default, { 'path' => '/etc/ipa/default.conf'})
}
