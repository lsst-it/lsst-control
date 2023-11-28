# frozen_string_literal: true

shared_examples 'gpsd' do
  it { is_expected.to contain_package('gpsd-minimal') }
  it { is_expected.to contain_package('gpsd-minimal-clients') }
end
