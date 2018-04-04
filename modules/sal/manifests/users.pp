class sal::users( $sal_pwd = '$1$LSST$clNeErmKCl0HbZmB9d2Bb.' , $salmgr_pwd = '$1$LSST$clNeErmKCl0HbZmB9d2Bb.' ,$lsst_users_home_dir = "/home" ) {
	#TODO Move all this data to hiera
	user{ 'sal':
		ensure => 'present',
		uid => '503' ,
		gid => '500',
		home => "${lsst_users_home_dir}/sal",
		managehome => true,
		require => Group['lsst'],
		password => $sal_pwd,
	}

	#TODO Move all this data to hiera
	user{ 'salmgr':
		ensure => 'present',
		uid => '501' ,
		gid => '500',
		home => "${lsst_users_home_dir}/salmgr",
		managehome => true,
		require => Group['lsst'],
		password => $salmgr_pwd,
	}
}