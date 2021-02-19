#
# @summary
#   Install TS Private Repo
#

class profile::ccs::ts_repo (
  String $username,
  String $password,
)
{
  yumrepo { 'ts_yum_private':
    ensure   => 'present',
    enabled  => true,
    gpgcheck => false,
    descr    => 'LSST Telescope and Site packages',
    baseurl  => "https://${username}:${password}@repo-nexus.lsst.org/nexus/repository/ts_yum_private",
    target   => '/etc/yum.repos.d/ts_yum_private.repo',
  }
}
