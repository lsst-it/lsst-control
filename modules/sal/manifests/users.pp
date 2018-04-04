class sal::users{
		
	#TODO Move all this data to hiera
	user{ 'sal':
		ensure => 'present',
		uid => '503' ,
		gid => '500',
		home => '/home/sal',
		managehome => true,
		require => Group['lsst'],
		password => '$1$PMfYrt2j$DAkeHmsz1q5h2XUsMZ9xn.',
	}

	#TODO Move all this data to hiera
	user{ 'salmgr':
		ensure => 'present',
		uid => '501' ,
		gid => '500',
		home => '/home/salmgr',
		managehome => true,
		require => Group['lsst'],
		password => '$1$PMfYrt2j$DAkeHmsz1q5h2XUsMZ9xn.',
	}
}