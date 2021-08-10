# @summary Install and configure the system for authnz using LSST IdM
#
# @example
#   include profile::system_authnz
class profile::ncsa::system_authnz {
  include ::profile::ncsa::allow_sudo
  include ::system_authnz
  include ::sshd
  include ::sssd
}
