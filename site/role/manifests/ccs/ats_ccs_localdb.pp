# Role for localdb
class role::ccs::ats_ccs_localdb {
  include profile::ccs::ccs
  include profile::ccs::localdb
}
