# Setup SAL DDS software and dependencies
class profile::sal (
  Array $miniconda_pkgs,
) {

  #include ::sal
  include ::miniconda
  include ::python

  miniconda::package { $miniconda_pkgs : }
}
