# @summary
#   Installs and configures OpenVPN Access Server with LDAP authentication and group setup.
#
# @param version
#   Sets version lock for OpenVPN package.
#
# @param bind_pw
#   Optional. LDAP bind password for OpenVPN Access Server.
#
class profile::core::openvpnas (
  String[1] $version,
  Optional[String[1]] $bind_pw = undef,
) {
  include profile::core::letsencrypt

  $fqdn    = fact('networking.fqdn')
  $le_root = "/etc/letsencrypt/live/${fqdn}"
  $ldap_pw = pick($bind_pw, 'testpassword')
  $sacli   = '/usr/local/openvpn_as/scripts/sacli'

  # --- CERTIFICATE MANAGEMENT ---
  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }

  class { 'openvpnas':
    manage_repo         => true,
    version             => $version,
    versionlock_enable  => true,
    versionlock_release => '1.el9',
    manage_service      => true,
    manage_web_certs    => true,
    cert_source_path    => $le_root,
    require             => Letsencrypt::Certonly[$fqdn],
  }

  exec { 'wait_for_openvpnas_socket':
    command => '/bin/true',
    unless  => '/usr/bin/test -S /usr/local/openvpn_as/etc/sock/sagent',
    require => Service['openvpnas'],
  }

  exec { 'wait_for_openvpnas_ready':
    command   => "${sacli} ConfigQuery > /dev/null 2>&1",
    tries     => 10,
    try_sleep => 3,
    timeout   => 60,
    require   => Exec['wait_for_openvpnas_socket'],
  }

  exec { 'set_auth_module_ldap':
    command => "${sacli} --key 'auth.module.type' --value 'ldap' ConfigPut",
    unless  => "${sacli} ConfigQuery | grep -q '\"auth.module.type\": \"ldap\"'",
    require => Exec['wait_for_openvpnas_ready'],
  }

  exec { 'set_ldap_primary':
    command => "${sacli} --key 'auth.ldap.0.server.0.host' --value 'ipa1.cp.lsst.org' ConfigPut",
    unless  => "${sacli} ConfigQuery | grep -q '\"auth.ldap.0.server.0.host\": \"ipa1.cp.lsst.org\"'",
    require => Exec['set_auth_module_ldap'],
  }

  exec { 'set_ldap_secondary':
    command => "${sacli} --key 'auth.ldap.0.server.1.host' --value 'ipa1.ls.lsst.org' ConfigPut",
    unless  => "${sacli} ConfigQuery | grep -q '\"auth.ldap.0.server.1.host\": \"ipa1.ls.lsst.org\"'",
    require => Exec['set_ldap_primary'],
  }

  exec { 'set_ldap_bind_dn':
    command => "${sacli} --key 'auth.ldap.0.bind_dn' --value 'uid=svc_openvpnas,cn=users,cn=accounts,dc=lsst,dc=cloud' ConfigPut",
    unless  => "${sacli} ConfigQuery | grep -q '\"auth.ldap.0.bind_dn\": \"uid=svc_openvpnas,cn=users,cn=accounts,dc=lsst,dc=cloud\"'",
    require => Exec['set_ldap_secondary'],
  }

  exec { 'set_ldap_bind_pw':
    command => "${sacli} --key 'auth.ldap.0.bind_pw' --value '${ldap_pw}' ConfigPut",
    unless  => "${sacli} ConfigQuery | grep -q '\"auth.ldap.0.bind_pw\":'",
    require => Exec['set_ldap_bind_dn'],
  }

  exec { 'set_ldap_users_base_dn':
    command => "${sacli} --key 'auth.ldap.0.users_base_dn' --value 'cn=accounts,dc=lsst,dc=cloud' ConfigPut",
    unless  => "${sacli} ConfigQuery | grep -q '\"auth.ldap.0.users_base_dn\": \"cn=accounts,dc=lsst,dc=cloud\"'",
    require => Exec['set_ldap_bind_pw'],
  }

  exec { 'set_ldap_uname_attr':
    command => "${sacli} --key 'auth.ldap.0.uname_attr' --value 'uid' ConfigPut",
    unless  => "${sacli} ConfigQuery | grep -q '\"auth.ldap.0.uname_attr\": \"uid\"'",
    require => Exec['set_ldap_users_base_dn'],
  }

  exec { 'enable_ldap_auth':
    command => "${sacli} --key 'auth.ldap.0.enable' --value 'true' ConfigPut",
    unless  => "${sacli} ConfigQuery | grep -q '\"auth.ldap.0.enable\": \"true\"'",
    require => Exec['set_ldap_uname_attr'],
  }

  exec { 'restart_openvpnas_after_ldap':
    command     => "${sacli} start",
    refreshonly => true,
    subscribe   => Exec['enable_ldap_auth'],
  }

  exec { 'create_group_vpn_default':
    command => "${sacli} --user 'vpn-default' --key 'type' --value 'group' UserPropPut && \
                ${sacli} --user 'vpn-default' --key 'group_declare' --value 'true' UserPropPut && \
                ${sacli} start",
    unless  => "${sacli} UserPropGet vpn-default | grep -q '\"group_declare\": \"true\"'",
    require => Exec['restart_openvpnas_after_ldap'],
    path    => ['/usr/local/openvpn_as/scripts', '/usr/bin', '/bin'],
  }

  exec { 'create_group_vpn_it':
    command => "${sacli} --user 'vpn-it' --key 'type' --value 'group' UserPropPut && \
                ${sacli} --user 'vpn-it' --key 'group_declare' --value 'true' UserPropPut && \
                ${sacli} start",
    unless  => "${sacli} UserPropGet vpn-it | grep -q '\"group_declare\": \"true\"'",
    require => Exec['create_group_vpn_default'],
    path    => ['/usr/local/openvpn_as/scripts', '/usr/bin', '/bin'],
  }

  exec { 'grant_admin_to_vpn_it':
    command => "${sacli} --user 'vpn-it' --key 'prop_superuser' --value 'true' UserPropPut && ${sacli} start",
    unless  => "${sacli} UserPropGet vpn-it | grep -q '\"prop_superuser\": \"true\"'",
    require => Exec['create_group_vpn_it'],
    path    => ['/usr/local/openvpn_as/scripts', '/usr/bin', '/bin'],
  }

  exec { 'restart_openvpnas_after_groups':
    command     => "${sacli} start",
    refreshonly => true,
    subscribe   => [Exec['create_group_vpn_default'], Exec['create_group_vpn_it'], Exec['grant_admin_to_vpn_it']],
    path        => ['/usr/local/openvpn_as/scripts', '/usr/bin', '/bin'],
  }

  file { '/root/ldap.py':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @(EOF/L)
      #!/usr/bin/env python3
      import re
      from pyovpn.plugin import *

      re_group = re.compile(r"^CN=([^,]+)", re.IGNORECASE)

      def ldap_groups_parse(res):
          ret = set()
          for g in res:
              m = re.match(re_group, g)
              if m:
                  ret.add(m.groups()[0])
          return ret

      def post_auth(authcred, attributes, authret, info):
          group = "vpn-default"
          proplist_save = {}
          if info.get('auth_method') == 'ldap':
              user_dn = info['user_dn']
              with info['ldap_context'] as l:
                  ldap_groups = set()
                  if hasattr(l, 'search_ext_s'):
                      import ldap
                      ldap_groups = l.search_ext_s(user_dn, ldap.SCOPE_SUBTREE, attrlist=["memberOf"])[0][1]['memberOf']
                      if ldap_groups:
                          ldap_groups = ldap_groups_parse(ldap_groups)
                  else:
                      search_base = info['search_base']
                      uname_attr = info['ldap_context'].authldap.parms['uname_attr']
                      search_filter = '(%s=%s)' % (uname_attr, user_dn)
                      attribute = 'memberOf'
                      if l.search(search_base, search_filter, attributes=[attribute]):
                          ldap_groups = getattr(l.entries[0], attribute).value
                          if not isinstance(ldap_groups, (list, tuple)):
                              ldap_groups = {ldap_groups}
                          if ldap_groups:
                              ldap_groups = ldap_groups_parse(ldap_groups)
                      else:
                          print('POST_AUTH: Ldap groups for user %r not found, please check filters %r' % (user_dn, search_filter))

                  if ldap_groups:
                      print("LDAP_GROUPS %s" % ldap_groups)
                      if 'vpn-it' in ldap_groups:
                          group = "vpn-it"
                      elif 'vpn-science' in ldap_groups:
                          group = "vpn-science"
                      elif 'vpn-users' in ldap_groups:
                          group = "vpn-users"
                      elif 'vpn-cucm' in ldap_groups:
                          group = "vpn-cucm"
                      elif 'vpn-tssw' in ldap_groups:
                          group = "vpn-tssw"
                      elif 'vpn-comm' in ldap_groups:
                          group = "vpn-comm"
                      elif 'vpn-clyso' in ldap_groups:
                          group = "vpn-clyso"

              if group:
                  print("POST_AUTH: Setting group %r for %r" % (group, user_dn))
                  authret['proplist']['conn_group'] = group
                  proplist_save['conn_group'] = group
              else:
                  print("POST_AUTH: No mapping found for %r, using default" % user_dn)
                  authret['proplist']['conn_group'] = group
                  proplist_save['conn_group'] = group
          return authret, proplist_save
      | EOF
  }

  exec { 'install_post_auth_script':
    command     => "${sacli} -k auth.module.post_auth_script --value_file=/root/ldap.py ConfigPut && ${sacli} start",
    refreshonly => true,
    subscribe   => File['/root/ldap.py'],
    require     => Exec['restart_openvpnas_after_groups'],
    path        => ['/usr/local/openvpn_as/scripts', '/usr/bin', '/bin'],
  }
}
