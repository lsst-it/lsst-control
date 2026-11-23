# @summary
#   Manage packages and services needed on different hardware platforms.
#   For *baremetal* only.
#
# @param manage_ipmi_exporter
#   If `true`, install prometheus ipmi_exporter on hosts with a managed BMC.
#
class profile::core::hardware (
  Boolean $manage_ipmi_exporter = false,
) {
  case fact('dmi.manufacturer') {
    /Advantech/, /VersaLogic Corporation/: {
      class { 'powertop':
        ensure => 'absent',
      }
    }
    default: {
      include powertop
    }
  }

  # lint:ignore:case_without_default
  case fact('dmi.product.name') {
    # XXX add a fact to check /sys/class/ipmi/ instead of white listing specific models
    /PowerEdge/: {
      include ipmi

      if fact('has_dellperc') {
        include profile::core::perccli
      }
    }
    /1114S-WN10RT/: {
      include ipmi
    }
    /SSG-640SP-E1CR90/: {
      include ipmi
    }
    /1115HS-TNR/: {
      include ipmi
    }

    /ASG-2015S-E1CR24H/: {
      include ipmi
    }
  }
  # On SM H12SSL-NT dmi.product.name == "Super Server", which isn't very helpful
  case fact('dmi.board.product') {
    /H12SSL-NT/: {
      include ipmi
    }
  }
  # lint:endignore

  # ipmi_exporter reads the BMC in-band via /dev/ipmi0, so it only makes sense
  # on hosts where the ipmi class was included above.
  if $manage_ipmi_exporter and defined(Class['ipmi']) {
    include prometheus::ipmi_exporter
  }

  # Enable AMD pstate on systems that support it
  if 'hw_pstate' in fact('cpuinfo.processor0.flags') {
    # https://docs.kernel.org/admin-guide/pm/amd-pstate.html
    profile::util::kernel_param { 'amd_pstate=active':
      reboot => false,
    }
  }
}
