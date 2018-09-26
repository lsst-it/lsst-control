class profile::ccs::ccs {

	################################################################################################################
	### Required Packages
	################################################################################################################

	package { 'unzip':
		ensure => installed,
	}

	################################################################################################################
	### Required Files
	################################################################################################################

	file { '/var/log/ccs' : 
		ensure => directory,
		mode => '1764',
		owner => ccs, 
		group => ccs,
	}

	file { ['/lsst', '/lsst/ccs', '/lsst/ccsadmin', '/lsst/ccsadmin/package-lists', '/etc/ccs' ] : 
		ensure => directory,
		mode => '1764',
	}

	file { '/usr/local/bin/ccssetup' :
		ensure => file,
		mode => '755',
		content => epp('profile/ccs/ccssetup.epp'),       
	}

	file { "/etc/profile.d/setup_ccssetup.sh":
		ensure => present,
		content => "eval `/usr/local/bin/ccssetup -s bash`\nccssetup\n",
	}

	file { "/etc/profile.d/setup_ccssetup.csh":
		ensure => present,
		content => "eval `/usr/local/bin/ccssetup -s csh`\nccssetup\n",
	}

	################################################################################################################
	### CCS Application configuration
	################################################################################################################

	# Every CCS deployment will require this configuration, it will depend on the hiera configuration the content
	file { '/lsst/ccsadmin/package-lists/ccsApplications.txt' :
		ensure => file,
		require => File['/lsst/ccsadmin/package-lists'] 
	}

	$ccsApplications_array = lookup("ccsApplications")

	$ccsApplications_array.each | $property_hash| {
		$property_hash.each | $property_key, $property_value| {
			ini_setting { "Updating property ${property_key} = ${property_value} in ccsApplications.txt file":
				ensure  => present,
				path    => '/lsst/ccsadmin/package-lists/ccsApplications.txt',
				section => 'ccs',
				setting => $property_key,
				value   => $property_value,
				require => File['/lsst/ccsadmin/package-lists/ccsApplications.txt']
			}
		}
	}

	vcsrepo { '/lsst/ccsadmin/release':
		ensure => present,
		provider => git,
		source => 'https://github.com/lsst-camera-dh/release',
		require => File['/lsst/ccsadmin/']
	}

	$ccsInstallationDir = lookup("ccsInstallationDir")
	exec { 'Execute CCS Self-Installer':
		path        => [ '/usr/bin', '/bin', '/usr/sbin' ], 
		command => "/lsst/ccsadmin/release/bin/install.py --ccs_inst_dir ${ccsInstallationDir} /lsst/ccsadmin/package-lists/ccsApplications.txt",
		onlyif => "test ! -d ${ccsInstallationDir}/bin/",
		require => [Vcsrepo["/lsst/ccsadmin/release"], File["/lsst/ccsadmin/package-lists/ccsApplications.txt"] ]
	}

	################################################################################################################
	### CCS Properties
	### Notes: Dynamic variables comes from Hiera, fixed and computed variables must by specified in puppet
	################################################################################################################

	$ccsGlobalProperties_filepath = '/etc/ccs/ccsGlobal.properties' 
	file { $ccsGlobalProperties_filepath :
		ensure => file,
		mode => '1764',
		#content => epp('profile/ccs/ccsGlobal.properties.epp'),
	}

	# Values from hiera are dynamic, computed values are static and must be added on the puppet script
	$ccsGlobalProperties_array = lookup({"name" => "ccsGlobalProperties", "default_value" => []})
	
	#An empty array won't iterate
	$ccsGlobalProperties_array.each | $property_hash|{
		$property_hash.each | $property_key, $property_value | {
			file_line{ "Updating CCS Global property ${property_key} = ${property_value}" :
				path => $ccsGlobalProperties_filepath,
				line => "${property_key} = ${property_value}",
				match => "${property_key}",
				require => File["${ccsGlobalProperties_filepath}"]
			}
		}
	}

	$udpCCSProperties_filepath = '/etc/ccs/udp_ccs.properties' 
	file { $udpCCSProperties_filepath :
		ensure => file,
		mode => '1764',
		content => epp('profile/ccs/udp_ccs.properties.epp'),
	}

	$udpCCSProperties_array = lookup({"name" => "udpCCSProperties", "default_value" => []})
	
	#An empty array won't iterate
	$udpCCSProperties_array.each | $property_hash|{
		$property_hash.each | $property_key, $property_value | {
			file_line{ "Updating UDP CCS Global property ${property_key} = ${property_value}" :
				path => $ccsGlobalProperties_filepath,
				line => "${property_key} = ${property_value}",
				match => "${property_key}",
				require => File[$udpCCSProperties_filepath]
			}
		}
	}

	java::oracle { 'jdk8' :
		ensure  => 'present',
		version_major => lookup("ccs::java_version_major"),
		version_minor => lookup("ccs::java_version_minor"),
		url_hash => lookup("ccs::java_url_hash"),
		java_se => 'jdk',
		before => Exec['update-java-alternatives']
	}

	################################################################################################################
	### JAVA Configuration
	################################################################################################################

	# Not clear why this is needed, but without it java is left pointing to openjdk
	exec { 'update-java-alternatives':
		path    => '/usr/bin:/usr/sbin',
		command => "alternatives --set java /usr/java/jdk*/jre/bin/java" ,
		unless  => "cmp -s /etc/alternatives/java /usr/java/jdk*/jre/bin/java",
	}
	
	################################################################################################################
	### Users
	################################################################################################################
	
	user { 'ccs':
		ensure => present,
		managehome => true,
	}
}
