# This class installs the puppet server
class profile::it::puppet_master(
  Stdlib::HTTPSUrl $control_repo_url,
  String $hiera_private_repo_url,
  Stdlib::HTTPSUrl $hiera_public_repo_url,
  String $hiera_sshkey,
  Stdlib::Absolutepath $hiera_sshkey_path = '/root/.ssh/id_rsa',
) {
  file{ '/root/README':
    ensure  => file,
    content => "Welcome to ${::fqdn}, this is a Puppet Master Server\n",
  }

  package{'epel-release':
    ensure => installed
  }

  package{'python36':
    ensure  => installed,
    require => Package['epel-release']
  }

  package{'sqlite':
    ensure => installed,
  }

  exec{'Ensure pip3.6 exists':
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    command => 'python3.6 -m ensurepip',
    onlyif  => 'test ! -f /usr/local/bin/pip3.6',
    require => Package['python36']
  }

  exec{'Installing PyYAML':
    path    => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'],
    command => 'pip3.6 install PyYAML',
    onlyif  => "[ -z \"$(pip3.6 list | grep PyYAML -o)\" ]",
    require => [Package['python36'], Exec['Ensure pip3.6 exists']]
  }

  exec{'Installing PrettyTable':
    path    => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'],
    command => 'pip3.6 install prettytable',
    onlyif  => "[ -z \"$(pip3.6 list | grep prettytable -o)\" ]",
    require => [Package['python36'], Exec['Ensure pip3.6 exists']]
  }

  package{'puppetserver':
    ensure => installed,
    source => 'https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm',
  }

  service{'puppetserver':
    ensure  => running,
    enable  => true,
    require => [
                  Ini_setting['Puppet master Alternative DNS names'],
                  Ini_setting['Puppet master certname'],
                  File['/etc/puppetlabs/puppet/autosign.conf']
                ]
  }

  file{'/etc/puppetlabs/puppet/puppet.conf':
    ensure  => present,
    require => Package['puppetserver']
  }

  ini_setting { 'Puppet master Alternative DNS names':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'dns_alt_names',
    value   => lookup('dns_alt_names'),
  }

  ini_setting { 'Puppet master certname':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'certname',
    value   => lookup('puppet_master_certname'),
  }

  file{'/etc/puppetlabs/puppet/autosign.conf':
    ensure => present
  }

  $autosign_domain_list = lookup('autosign_servers')

  $autosign_domain_list.each | $domain | {

    file_line { "Ensure ${$domain} in autosign.conf":
      ensure  => present,
      path    => '/etc/puppetlabs/puppet/autosign.conf',
      line    => "*.${domain}",
      match   => $domain,
      require => File['/etc/puppetlabs/puppet/autosign.conf']
    }

  }

  file_line{'Make sure local dns record':
    ensure => present,
    line   => "${::ipaddress}\t${::fqdn}",
    path   => '/etc/hosts',
  }

  file_line{ 'Update Ruby libs puppetserver configuration' :
    ensure => present,
    line   => '    ruby-load-path: [/opt/puppetlabs/puppet/lib/ruby/vendor_ruby, /opt/puppetlabs/puppet/cache/lib]',
    match  => 'ruby-load-path*',
    path   => '/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf',
  }

  ensure_resources('file', {
    '/root/.ssh' => {
      mode   => '0700',
      owner  => 'root',
      group  => 'root',
      ensure => directory,
    },
  })

  file{ '/root/.ssh/known_hosts':
    ensure => present,
    mode   => '0600',
    owner  => 'root',
    group  => 'root',
  }

  # XXX What is this key used for? -JCH
  file{'/etc/ssh/puppet_id_rsa_key':
    ensure  => file,
    mode    => '0600',
    content => lookup('puppet_ssh_id_rsa')
  }

  exec{'install R10K':
    command => '/opt/puppetlabs/puppet/bin/gem install r10k',
    onlyif  => '/usr/bin/test ! -x /opt/puppetlabs/puppet/bin/r10k'
  }

  file{'/etc/puppetlabs/r10k/':
    ensure => directory,
  }

  exec{'github-to-known-hosts':
    path    => '/usr/bin/',
    command => 'ssh-keyscan github.com > /root/.ssh/known_hosts',
    onlyif  => "test -z \"$(grep github.com /root/.ssh/known_hosts -o)\"",
    require => File['/root/.ssh/known_hosts']
  }

  file{'/etc/puppetlabs/r10k/r10k.yaml':
    ensure  => file,
    content => epp('profile/it/r10k.epp',
      {
        'control_repo_url'       => $control_repo_url,
        'hiera_private_repo_url' => $hiera_private_repo_url,
        'hiera_public_repo_url'  => $hiera_public_repo_url,
      }
    )
  }

  ensure_resources('file', {
    dirname($hiera_sshkey_path) => {
      mode    => '0700',
      ensure => directory,
    },
  })

  file{ $hiera_sshkey_path:
    ensure  => file,
    mode    => '0600',
    content => $hiera_sshkey,
  }

  firewalld::custom_service{'puppet':
    short       => 'puppet',
    description => 'Puppet Client access Puppet Server',
    port        => [
      {
        'port'     => '8140',
        'protocol' => 'tcp',
      },
      {
        'port'     => '8140',
        'protocol' => 'udp',
      },
    ],
  }

  firewalld_service { 'Allow puppet port on this server':
    ensure  => 'present',
    service => 'puppet',
  }
}
