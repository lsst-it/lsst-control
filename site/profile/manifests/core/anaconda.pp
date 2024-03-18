# @summary
#   Installs anaconda
#
# @param anaconda_version
#   sets the version of anaconda you want to install, check: https://repo.anaconda.com/archive/
#
# @param python_env_name
#   if exist, sets the name of the virtual environment
#
# @param python_env_version
#   if exist, sets the version of python for the virtual environment
#
# @param conda_packages
#   if contains at least 1 package (name, channel and version) will be installed
#    
class profile::core::anaconda (
  String[1] $anaconda_version,
  String[1] $python_env_name,
  String[1] $python_env_version,
  Hash $conda_packages,
) {
  case $facts['os']['family'] {
    'RedHat': {
      ensure_packages('wget')
      exec { 'install_anaconda':
        command => "/bin/wget https://repo.anaconda.com/archive/${anaconda_version}-Linux-x86_64.sh -O /tmp/anaconda_installer.sh && /bin/bash /tmp/anaconda_installer.sh -b -p /opt/anaconda",
        creates => '/opt/anaconda/bin/conda',
        path    => '/usr/bin:/bin:/opt/anaconda/bin',
        require => Package['wget'],
      }
    }
    default: {
      notify { 'This Anaconda installation is only for RedHat family': }
    }
  }
  # Create a Conda environment with Python if parameters are set
  exec { 'create_conda_env':
    command => "/opt/anaconda/bin/conda create -y --name ${python_env_name} python=${python_env_version}",
    creates => "/opt/anaconda/envs/${python_env_name}/",
    require => Exec['install_anaconda'],
  }
  file { '/etc/profile.d/conda_source.sh':
    ensure  => file,
    mode    => '0644',
    content => "source /opt/anaconda/bin/activate ${python_env_name}",
    require => Exec['create_conda_env'],
  }
  # Install libmamba inside the environment with conda
  exec { 'install_libmamba_env':
    command => "/opt/anaconda/bin/conda install -y -n ${python_env_name} conda-libmamba-solver",
    creates => "/opt/anaconda/envs/${python_env_name}/lib/libmamba.so",
    path    => ['/usr/bin', '/bin', '/opt/anaconda/bin'],
    require => Exec['create_conda_env'],
  }
  # Sets libmamba as dependencies solver
  exec { 'set_libmamba':
    command => 'conda config --set solver libmamba',
    unless  => 'conda config --get solver | grep libmamba',
    path    => ['/usr/bin', '/bin', '/opt/anaconda/bin'],
    require => Exec['install_libmamba_env'],
  }
  #cycle and install conda stuff
  if !empty($conda_packages) {
    $conda_packages.each |$package_name, $package_info| {
      exec { "install_${package_name}_via_conda":
        command => "conda install -y -n ${python_env_name} -c ${package_info['channel']} ${package_name}=${package_info['version']}",
        path    => ['/usr/bin', '/bin', '/opt/anaconda/bin'],
        require => Exec['set_libmamba'],
        unless  => "conda list -n ${python_env_name} | grep ${package_name} | grep ${package_info['version']}",
      }
    }
  }
}
