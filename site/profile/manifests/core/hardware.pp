# @summary
#   Manage packages and services needed on different hardware platforms.
class profile::core::hardware {

  # lint:ignore:case_without_default
  case $facts.dig('dmi', 'product', 'name') {
    /PowerEdge/: {
      include ipmi
      # LLDP will be added in the future
    }
  }
  # lint:endignore
}
