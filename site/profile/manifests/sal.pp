# Setup SAL DDS software and dependencies
class profile::sal (
  Array $miniconda_pkgs,
) {

  include ::sal2
  include ::miniconda
  include ::python

  miniconda::package { $miniconda_pkgs : }
}
