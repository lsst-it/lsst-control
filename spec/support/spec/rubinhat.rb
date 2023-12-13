# frozen_string_literal: true

shared_examples 'rubinhat' do
  it do
    is_expected.to contain_pi__config__fragment('rubinhat').with(
      content: <<~CONTENT,
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
      CONTENT
    )
  end

  it do
    is_expected.to contain_systemd__udev__rule('rubinhat.rules').with(
      rules: [
        'KERNEL=="ttyS[0-9]*", GROUP="70014", MODE="0660"',
        'KERNEL=="ttyAMA[0-9]*", GROUP="70014", MODE="0660"',
        'ATTR{iomem_base}=="0xFE201000", SYMLINK:="serial0"',
        'ATTR{iomem_base}=="0xFE201400", SYMLINK:="serial1"',
        'ATTR{iomem_base}=="0xFE201600", SYMLINK:="serial2"',
        'ATTR{iomem_base}=="0xFE201800", SYMLINK:="serial3"',
        'ATTR{iomem_base}=="0xFE201A00", SYMLINK:="serial4"',
      ],
    )
  end
end
