class profile::ts::nexusctio(
  Hash $repos,
) {
  unless (empty($repos)) {
    create_resources('yumrepo', $repos)
  }
}
