# @summary
#   Manage packages and services needed on different hardware platforms.
class profile::core::hardware {
  # lint:ignore:case_without_default
  case $facts.dig('dmi', 'product', 'name') {
    /PowerEdge/: {
      include ipmi
      class { 'lldpd':
        manage_facts => true,
        manage_jq    => true,
      }
    }
  }
  # lint:endignore
}
