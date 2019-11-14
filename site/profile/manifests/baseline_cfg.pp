# @summary Default setup for all hosts
#
# @example
#   include profile::baseline_cfg
class profile::baseline_cfg {
    include ::augeasproviders::instances
    include ::baseline_cfg
    include ::chrony
    include ::rsyslog::client
    include ::sshd
    include ::timezone

    # OS specific includes
    case $facts['os']['family'] {
        'RedHat': {
            include ::pakrat_client
        }
        default: {
            fail( 'Unsupported OS family' )
        }
    }
}
