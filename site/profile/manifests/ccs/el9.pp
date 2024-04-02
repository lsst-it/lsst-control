# @summary
#   EL9-specific requirements.
#
# @param rpms
#   Hash of package/rpm pairs to install.
# @param pkgurl
#   String specifying url to fetch binaries from
# @param pkgurl_user
#   String specifying username for pkgurl
# @param pkgurl_pass
#   String specifying password for pkgurl
#
class profile::ccs::el9 (
  Hash[String,String] $rpms = {
    'compat-bin' => 'compat-bin-1.0.0-1.el9.noarch.rpm',
  },
  String $pkgurl = $profile::ccs::common::pkgurl,
  Variant[Sensitive[String[1]],String[1]] $pkgurl_user = $profile::ccs::common::pkgurl_user,
  Sensitive[String[1]] $pkgurl_pass = $profile::ccs::common::pkgurl_pass,
) {
  $rpm_opts = {
    ensure   => 'latest',
    provider => 'rpm',
  }

  $rpms.each |$package, $rpm| {
    $file = "/var/tmp/${rpm}"

    archive { $file:
      ensure   => present,
      source   => "${pkgurl}/${rpm}",
      username => $pkgurl_user.unwrap,
      password => $pkgurl_pass.unwrap,
    }
    package { $package:
      source => $file,
      *      => $rpm_opts,
    }
  }
}
