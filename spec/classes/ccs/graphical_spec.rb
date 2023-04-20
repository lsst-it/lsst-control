# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ccs::graphical' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      if facts[:os]['release']['major'] == '7'
        it do
          is_expected.to contain_yum__group('GNOME Desktop').with(
            ensure: 'present',
            timeout: '1800',
          )
                                                            .that_notifies('Package[gnome-initial-setup]')
                                                            .that_notifies('Package[libvirt-daemon]')
        end

        it do
          is_expected.to contain_yum__group('MATE Desktop').with(
            ensure: 'present',
            timeout: '900',
          )
        end
      else
        it do
          is_expected.to contain_yum__group('Server with GUI').with(
            ensure: 'present',
            timeout: '900',
          )
                                                              .that_notifies('Package[gnome-initial-setup]')
                                                              .that_notifies('Package[libvirt-daemon]')
        end
      end

      it { is_expected.to contain_package('gnome-initial-setup').with_ensure('purged') }
      it { is_expected.to contain_package('libvirt-daemon').with_ensure('purged') }
    end
  end
end
