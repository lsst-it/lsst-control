# @summary
#   Add (or remove) nvidia settings.
#
# @param ensure
#   String saying whether to install ('present') or remove ('absent') module.
#
# TODO actually install the driver if possible.
class profile::ccs::nvidia (String $ensure = 'present') {
  if $ensure =~ /(present|absent)/ {
    ## This takes care of the /etc/kernel/postinst.d/ part,
    ## so long as the nvidia driver is installed with the dkms option.
    ensure_packages(['dkms', 'gcc', 'kernel-devel', 'kernel-headers'])

    $file = 'disable-nouveau.conf'

    file { "/etc/modprobe.d/${file}":
      ensure => $ensure,
      source => "puppet:///modules/${module_name}/ccs/nvidia/${file}",
    }

    $grub = '/etc/default/grub'

    case $ensure {
      'present': {
        exec { 'Blacklist nouveau':
          path    => ['/usr/bin'],
          unless  => "grep -q rdblacklist=nouveau ${grub}",
          command => "sed -i '/^GRUB_CMDLINE_LINUX=/ s/\"\$/ rdblacklist=nouveau\"/' ${grub}",
          notify  => Exec['grub and dracut nvidia'],
        }
      }
      'absent': {
        exec { 'Unblacklist nouveau':
          path    => ['/usr/bin'],
          onlyif  => "grep -q rdblacklist=nouveau ${grub}",
          command => "sed -i 's/ *rdblacklist=nouveau//' ${grub}",
          notify  => Exec['grub and dracut nvidia'],
        }
      }
      default: {}
    }

    if fact('efi') {
      $grubfile = '/boot/efi/EFI/centos/grub.cfg'
    } else {
      $grubfile = '/boot/grub2/grub.cfg'
    }

    exec { 'grub and dracut nvidia':
      path        => ['/usr/sbin', '/usr/bin'],
      command     => "sh -c 'grub2-mkconfig -o ${grubfile} && dracut -f'",
      refreshonly => true,
    }
  }
}
