# @summary Install and configure the system for authnz using LSST IdM
#
# @example
#   include profile::system_authnz
class profile::system_authnz {

    include ::system_authnz
    include ::sshd
    include ::sssd
    include ::sudo   # saz::sudo

}
