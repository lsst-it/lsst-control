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
      ],
    )
  end
end
