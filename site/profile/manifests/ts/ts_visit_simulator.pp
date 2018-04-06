class ts_visit_simulator{
	include sal
	yum::group { 'Development Tools':
		ensure  => present,
		timeout => 600,
	}
	yum::group { 'Development Libraries':
		ensure  => present,
		timeout => 600,
	}
}