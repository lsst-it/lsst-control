# @summary
#   Manage packages and services needed on different hardware platforms.
class profile::core::hardware {
  # lint:ignore:case_without_default
  case $facts.dig('dmi', 'product', 'name') {
    # XXX add a fact to check /sys/class/ipmi/ instead of white listing specific models
    /PowerEdge/, /1114S-WN10RT/: {
      include ipmi
    }
  }
  # lint:endignore
}
