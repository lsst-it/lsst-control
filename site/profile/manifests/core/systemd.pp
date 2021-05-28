class profile::core::systemd(
  Optional[Hash[String, Hash]] $dropin_file = undef,
) {

  if $dropin_file {
    ensure_resources('systemd::dropin_file', $dropin_file)
  }
}
