#
class profile::ncsa::allow_qualys_scan (
  String $ip,
){

    $user  = 'qualys'
    $group = 'qualys'

    ### qualys NCSA IRST Qualys
    group { $group:
        ensure => 'present',
        name   => $group,
        gid    => '19999',
    }

    user { $user:
        ensure         => 'present',
        name           => $user,
        comment        => 'NCSA IRST Qualys - security@ncsa.illinois.edu',
        gid            => '19999',
        home           => '/home/qualys',
        managehome     => true,
        password       => '!!',
        purge_ssh_keys => true,
        shell          => '/bin/bash',
        uid            => '19999',
    }

    file {
        '/home/qualys':
            ensure => 'directory',
            mode   => '0700',
        ;
        '/home/qualys/.ssh':
            ensure => 'directory',
            mode   => '0700',
        ;
        '/home/qualys/.ssh/authorized_keys':
            ensure => 'present',
            mode   => '0600',
        ;
        default:
            owner => $user,
            group => $group,
        ;
    }

    ssh_authorized_key { 'qualys@LSST':
        user => $user,
        type => 'ssh-rsa',
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAxuarU7erT7vr9gbp5qRiGFKLHftqRw9cdaqZCeICQ3sb84O40m9UspHhzhW5FAQBM22qt0aG37QKeHk2B/poDZeNwj4iE5WRcPtXgaqCkg2vTbnv7ErJyVJNr78x32ngXZP+jd2dL5tXZqUQr/ZHJsA9wTv4qccrSCd2t++7mQdw5LdXbdpaMqqKFKolRLJ7CBWQgguSKwM98uF5uV2971JJRqUzKZndiJUipHbuAV6sN7RiNQSmU4rvOWVxLGvJMHoJO5wUVbEH2X9zaZ3zDn/gG96Vqc/uoo3qYNZQFPRCxU9yG1FKXuMoLj77d0/m1s8au26LYPAlZ/K5pVEaAQ==', #lint:ignore:140chars
    }

    ### ACCESS.CONF
    pam_access::entry { "Allow ${user} ssh from ${ip}":
        user       => $user,
        origin     => $ip,
        permission => '+',
        position   => '-1',
    }

    ### IPTABLES
    firewall {
        "299 profile_ncsa_allow_qualys_scan allow TCP connections from ${user}" :
            proto    => 'tcp',
        ;
        "299 profile_ncsa_allow_qualys_scan allow UDP connections from ${user}" :
            proto    => 'udp',
        ;
        default:
            source   => $ip,
            action   => 'accept',
            provider => 'iptables',
        ;
    }

#    ### TCP WRAPPERS
#    tcpwrappers::allow { "tcpwrappers allow SSH from host '${ip}' for qualys scan":
#        service => 'sshd',
#        address => $ip,
#    }

    ### SSHD_CONFIG
    # Defaults
    $config_defaults = { 'notify' => Service[ sshd ],
    }
    $config_match_defaults = $config_defaults + { 'position' => 'before first match' }

    $match_condition = "User ${user}"

    $match_params = {
                      'AllowGroups'           => [ $group ],
                      'AllowUsers'            => [ "${user}@${ip}" ],
                      'PubkeyAuthentication'  => 'yes',
                      'AuthenticationMethods' => 'publickey',
                      'Banner'                => 'none',
                      'MaxSessions'           => '10',
                      'X11Forwarding'         => 'no',
                    }

    sshd_config_match {
        $match_condition :
        ;
        default: * => $config_match_defaults,
        ;
    }

    $match_params.each | $key, $val | {
        sshd_config {
            "${match_condition} ${key}" :
                key       => $key,
                value     => $val,
                condition => $match_condition,
            ;
            default: * => $config_defaults,
            ;
        }
    }

}
