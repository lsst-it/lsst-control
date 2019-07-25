lookup('classes', Array[String], 'unique').include

$files = lookup(
  name          => 'files',
  value_type    => Variant[Hash[String, Hash], Undef],
  default_value => undef,
)

if ($files) {
  ensure_resources('file', $files)
}
