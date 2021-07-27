# @summary
#   systemd hooks
#
# @param dropin_file
#   systemd::dropin_file hiera hook
#
# @param tmpfile
#   systemd::tmpfile hiera hook
#
class profile::core::systemd(
  Optional[Hash[String, Hash]] $dropin_file = undef,
  Optional[Hash[String, Hash]] $tmpfile = undef,
) {
  include systemd

  if $dropin_file {
    ensure_resources('systemd::dropin_file', $dropin_file)
  }

  # XXX upstream this to camptocamp/systemd and this class can be replaced with ::systemd
  if $tmpfile {
    ensure_resources('systemd::tmpfile', $tmpfile)
  }

  systemd::unit_file { 'reboot.target':
    source => "puppet:///modules/${module_name}/systemd/reboot.target",
  }
}
