#
# @summary
#   Common functionality needed by ccs nodes.
#
class profile::ccs::common(
  Boolean $sysctls = true,
) {
  include profile::ccs::clustershell
  include profile::ccs::facts
  include profile::ccs::home
  include profile::ccs::monitoring
  include profile::ccs::postfix
  include profile::ccs::profile_d

  if ($sysctls) {
    include profile::ccs::sysctl
  }

  include ccs_software
  include java_artisanal

  Class['java_artisanal']
  -> Class['ccs_software']

  ssh::server::match_block { 'ccs':
    type    => 'User',
    options => {
      'AuthorizedKeysFile' => '.ssh/authorized_keys',
    }
  }
}
