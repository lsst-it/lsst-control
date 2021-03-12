# @summary Install headerservice and dependencies from miniconda
#
# Install headerservice and dependencies from miniconda.
# Also setup firewall exceptions.
#
# @param allowed_subnets
#        Web access allowed from these networks
#
# @param fitsio_version
#        Version string for fitsio conda package
#
# @param version
#        Version string for headerservice conda package
#
class profile::headerservice_conda (
  Array  $allowed_subnets,
  # String $fitsio_version,
  # String $headerservice_version,
) {

  # CONDA PACKAGES
  # $conda_pkgs = [
  #   'ipython',
  #   'pyyaml',
  #   "fitsio==${fitsio_version}",
  #   "headerservice=${headerservice_version}",
  # ]
  # miniconda::package { $conda_pkgs : }

  # FIREWALL
  $allowed_subnets.each | $source |
  {
    firewall { "510 ${module_name}::headerservice_conda allow access to HeaderService from ${source}" :
      dport  => [8000,9000],
      source => $source,
      action => 'accept',
    }
  }

}
