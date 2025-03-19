# frozen_string_literal: true

require 'spec_helper'

describe 'profile::util::xfce' do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it {
        is_expected.to contain_yum__group('Xfce')
          .with(
            ensure: 'present',
            timeout: 600
          )
      }

      context 'when wayland is false' do
        let(:params) { { wayland: false } }

        it {
          is_expected.to contain_file_line('disable_wayland')
            .with(
              path: '/etc/gdm/custom.conf',
              match: '^#?WaylandEnable=',
              line: 'WaylandEnable=false'
            )
        }
      end

      context 'when wayland is true' do
        let(:params) { { wayland: true } }

        it {
          is_expected.to contain_file_line('enable_wayland')
            .with(
              path: '/etc/gdm/custom.conf',
              match: '^#?WaylandEnable=',
              line: 'WaylandEnable=true'
            )
        }
      end

      context 'when graphical is true' do
        let(:params) { { graphical: true } }

        it {
          is_expected.to contain_exec('set_systemd_graphical.target')
            .with(
              command: 'systemctl set-default graphical.target',
              unless: 'systemctl get-default | grep -q graphical.target',
              path: ['/bin', '/usr/bin', '/sbin', '/usr/sbin']
            )
        }
      end

      context 'when graphical is false' do
        let(:params) { { graphical: false } }

        it {
          is_expected.to contain_exec('set_systemd_multi-user.target')
            .with(
              command: 'systemctl set-default multi-user.target',
              unless: 'systemctl get-default | grep -q multi-user.target',
              path: ['/bin', '/usr/bin', '/sbin', '/usr/sbin']
            )
        }
      end
    end
  end
end
