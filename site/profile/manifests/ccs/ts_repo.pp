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
    descr    => 'LSST Telescope and Site Private Packages',
    baseurl  => "https://${username}:${password}@repo-nexus.lsst.org/nexus/repository/ts_yum_private",
    target   => '/etc/yum.repos.d/ts_yum_private.repo',
  }
  yumrepo { 'lsst-ts':
    ensure   => 'present',
    enabled  => true,
    gpgcheck => false,
    descr    => 'LSST Telescope and Site Packages',
    baseurl  => 'https://repo-nexus.lsst.org/nexus/repository/ts_yum/releases',
    target   => '/etc/yum.repos.d/ts_yum_private.repo',
  }
  yumrepo { 'lsst-ts-test':
    ensure   => 'present',
    enabled  => true,
    gpgcheck => false,
    descr    => 'LSST Telescope and Site Test Package',
    baseurl  => 'https://repo-nexus.lsst.org/nexus/repository/ts_yum/test',
    target   => '/etc/yum.repos.d/ts_yum_private.repo',
  }
}
