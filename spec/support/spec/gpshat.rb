# frozen_string_literal: true

shared_examples 'gpshat' do
  include_examples 'gpsd'

  it do
    is_expected.to contain_pi__config__fragment('gpshat').with(
      content: <<~CONTENT,
      dtoverlay=pps-gpio,gpiopin=4
      enable_uart=1
      init_uart_baud=9600
      CONTENT
    )
  end

  it { is_expected.to contain_pi__cmdline__parameter('console=tty1') }

  it { is_expected.to contain_kmod__load('pps_gpio') }

  it do
    is_expected.to contain_class('profile::pi::gpsd').with(
      options: '-n /dev/ttyS0 /dev/pps0',
    )
  end

  it do
    expect(catalogue.resource('file', '/etc/chrony.conf')[:content]).to include(
      <<~CONTENT,
      refclock SHM 0 refid NMEA offset 0.200
      refclock PPS /dev/pps0 refid PPS lock NMEA
      CONTENT
    )
  end
end
