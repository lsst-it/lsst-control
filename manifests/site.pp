lookup('classes', Array[String], 'unique', []).include

$files = lookup(
  name          => 'files',
  value_type    => Variant[Hash[String, Hash], Undef],
  merge         => 'deep',
  default_value => undef,
)

if ($files) {
  ensure_resources('file', $files)
}

$packages = lookup(
  name          => 'packages',
  value_type    => Variant[Array[String], Undef],
  merge         => 'unique',
  default_value => undef,
)

if ($packages) {
  ensure_packages($packages)
}
