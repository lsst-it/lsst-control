class role::ccs::ats_ccs_localdb {
	include profile::default
	include profile::it::ssh_server
	include profile::ccs::ccs
	include profile::ccs::localdb
}
