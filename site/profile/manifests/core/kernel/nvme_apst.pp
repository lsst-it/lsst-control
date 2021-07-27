# @summary
#   Disable NVMe APST support
#
#   See: https://wiki.archlinux.org/title/Solid_state_drive/NVMe#Power_Saving_(APST)
#
class profile::core::kernel::nvme_apst {
  profile::util::kernel_param { 'nvme_core.default_ps_max_latency_us=0': }
}
