# Role to be applied to any influxdb deployment
class role::it::influxdb{
  include profile::default
  include profile::it::influxdb
}
