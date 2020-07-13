# @summary
#   Same as common but excludes icinga agent

class profile::it::icinga_satellite {
  include profile::core::uncommon
  include profile::core::remi
}
