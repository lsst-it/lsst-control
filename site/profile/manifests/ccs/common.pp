# @summary
#   Common functionality needed by ccs nodes.
#
# @param sysctls
#   if `true`, enable `profile::ccs::sysctl` sysctls.
# @param pkgurl
#   String specifying URL to fetch sources from
# @param pkgurl_user
#   String specifying username for pkgurl
# @param pkgurl_pass
#   String specifying password for pkgurl
#
class profile::ccs::common (
  Boolean $sysctls = true,
  String $pkgurl = 'https://example.org',
  String $pkgurl_user = 'someuser',
  String $pkgurl_pass = 'somepass',
) {
  include clustershell
  include profile::ccs::cfs
  include profile::ccs::home
  include profile::ccs::monitoring
  include profile::ccs::postfix
  include profile::ccs::profile_d

  if ($sysctls) {
    include profile::daq::sysctl
  }

  include ccs_software
  include java_artisanal
  include java_artisanal::java17
  include maven

  Class['java_artisanal']
  -> Class['ccs_software']

  ssh::server::match_block { 'ccs':
    type    => 'User',
    options => {
      'AuthorizedKeysFile' => '.ssh/authorized_keys',
    },
  }
}
