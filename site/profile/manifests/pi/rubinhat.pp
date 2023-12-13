# @summary
#   Configuration to enable a Rubin Observatory Raspberry Pi hat.
#
class profile::pi::rubinhat {
  # https://confluence.lsstcorp.org/pages/viewpage.action?spaceKey=LTS&title=Rubin+Raspberry+Pi+Pin+Configuration+Issue
  pi::config::fragment { 'rubinhat':
    # lint:ignore:strict_indent
    content => @("CONTENT"),
      enable_uart=1
      dtoverlay=disable-bt
      dtoverlay=uart1
      dtoverlay=uart2
      dtoverlay=uart3
      dtoverlay=uart4
      dtoverlay=uart5
      gpio=18=ip
      gpio=11,17,23=op,dh
      gpio=3,7,24=op
      | CONTENT
    # lint:endignore
  }

  if defined(Class['profile::core::docker']) {
    $group = Class['profile::core::docker']['socket_group']
  } else {
    $group = '70014'
  }

  systemd::udev::rule { 'rubinhat.rules':
    rules => [
      "KERNEL==\"ttyS[0-9]*\", GROUP=\"${group}\", MODE=\"0660\"",
      "KERNEL==\"ttyAMA[0-9]*\", GROUP=\"${group}\", MODE=\"0660\"",
      "ATTR{iomem_base}==\"0xFE201000\", SYMLINK:=\"serial0\"",
      "ATTR{iomem_base}==\"0xFE201400\", SYMLINK:=\"serial1\"",
      "ATTR{iomem_base}==\"0xFE201600\", SYMLINK:=\"serial2\"",
      "ATTR{iomem_base}==\"0xFE201800\", SYMLINK:=\"serial3\"",
      "ATTR{iomem_base}==\"0xFE201A00\", SYMLINK:=\"serial4\"",
    ],
  }
}
