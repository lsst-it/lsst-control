# frozen_string_literal: true

shared_examples 'gpsd' do
  it { is_expected.to contain_package('gpsd-minimal') }
  it { is_expected.to contain_package('gpsd-minimal-clients') }

  it do
    is_expected.to contain_systemd__dropin_file('gpsd.conf').with(
      unit: 'gpsd.socket',
      content: %r{#ListenStream=\[::1\]:2947}
    )
  end
end
