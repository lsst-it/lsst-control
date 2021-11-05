# @summary
#   Install and manage Duo 2fa proxy

class profile::core::duo (
  String $ikey,
  String $skey,
  String $api,
) {
  class { 'duo_unix':
    ensure            => 'present',
    manage_ssh        => false,
    usage             => 'login',
    ikey              => $ikey,
    skey              => $skey,
    host              => $api,
    motd              => 'no',
    manage_pam        => false,
    manage_repo       => true,
    fallback_local_ip => 'no',
    failmode          => 'safe',
    pushinfo          => 'yes',
    autopush          => 'yes',
    prompts           => 3,
    accept_env_factor => 'no'
  }
}
