class profile::core::debugutils(
  Array[String] $packages,
) {
  unless (empty($packages)) {
    ensure_packages($packages)
  }
}
