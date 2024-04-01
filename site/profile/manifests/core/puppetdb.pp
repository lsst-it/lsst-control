# @summary
#   Install puppetdb
#
# @param ldap_servers
#  An array of LDAP servers to use for authentication
#
# @param ldap_bind_user
#  The user to use for binding to the LDAP server(s)
#
# @param ldap_bind_pass
#  The password to use for binding to the LDAP server(s)
#
class profile::core::puppetdb (
  Array[String[1]] $ldap_servers,
  Sensitive[String[1]] $ldap_bind_user,
  Sensitive[String[1]] $ldap_bind_pass,
) {
  include apache
  include apache::mod::authnz_ldap
  include apache::mod::ldap
  include profile::core::letsencrypt
  include puppetdb

  $fqdn    = fact('networking.fqdn')
  $le_root = "/etc/letsencrypt/live/${fqdn}"
  # apache wants a space separated list of ldap servers as part of the ldap
  # url...
  $try_ldap_servers = join($ldap_servers, ' ')

  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }

  # A cron job is needed to restart apache if the letsencrypt cert is renewed.
  # We are being lazy and just restart apache every day at noon.
  cron::job { 'restart-apache-on-letsencrypt-renewal':
    minute      => '0',
    hour        => '15',
    date        => '*',
    month       => '*',
    weekday     => '*',
    command     => '/bin/systemctl restart httpd',
    description => 'Restart apache incase the letsencrypt cert is renewed',
  }

  apache::vhost { 'redirect-https':
    servername    => $fqdn,
    port          => 80,
    docroot       => '/var/www/html',
    redirect_dest => "https://${fqdn}",
  }

  apache::vhost {
    default:
      servername          => $fqdn,
      docroot             => '/var/www/html',
      ssl                 => true,
      ssl_cert            => "${le_root}/fullchain.pem",
      ssl_key             => "${le_root}/privkey.pem",
      rewrites            => [
        {
          comment      => 'Eliminate Trace and Track',
          rewrite_cond => ['%{REQUEST_METHOD} ^(TRACE|TRACK)'],
          rewrite_rule => [' .* - [F]'],
        },
      ],
      proxy_preserve_host => true,
      # XXX show_diff isn't part of a forge release yet
      # https://github.com/puppetlabs/puppetlabs-apache/pull/2536
      # show_diff           => false,  # don't show ldap bind pass in diff
      directories         => [
        {
          path                    => '/',
          provider                => 'location',
          auth_name               => 'IPA Authentication',
          auth_type               => 'Basic',
          auth_basic_provider     => 'ldap',
          # quotes are required around the ldap url because it contains a space
          auth_ldap_url           => "\"ldaps://${try_ldap_servers}/cn=users,cn=accounts,dc=lsst,dc=cloud?uid?sub?(objectClass=posixAccount)\"",
          auth_ldap_bind_dn       => "uid=${ldap_bind_user.unwrap},cn=users,cn=accounts,dc=lsst,dc=cloud",
          auth_ldap_bind_password => $ldap_bind_pass.unwrap,
          require                 => [
            'ldap-group cn=admins,cn=groups,cn=accounts,dc=lsst,dc=cloud',
            'ldap-group cn=puppetdb,cn=groups,cn=accounts,dc=lsst,dc=cloud',
          ],
        },
      ],
      ;
    'puppetboard-proxy':
      port       => 443,
      proxy_pass => {
        path => '/',
        url  => 'http://127.0.0.1:8088/',
      },
      ;
    'puppetdb-proxy':
      port       => 8443,
      proxy_pass => {
        path => '/',
        url  => 'http://127.0.0.1:8080/',
      },
      ;
  }
}
