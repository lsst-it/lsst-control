class profile::core::tmpfile(
  Optional[Hash[String, Hash]] $file = undef,
) {

  if $file {
    ensure_resources('systemd::tmpfile', $file)
  }
}
