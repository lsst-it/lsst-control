# @summary Allow passwordless root access from the xcat master
#
# @example
#   include profile::ncsa::xcat_client
#
class profile::ncsa::xcat_client {
    include ::xcat::client
}

