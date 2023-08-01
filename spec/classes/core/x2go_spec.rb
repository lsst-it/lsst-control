# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::x2go' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:pre_condition) do
        <<~PP
        sudo::conf { 'bogus':
          content => '%foo ALL=(bar) NOPASSWD: ALL',
        }
        PP
      end

      context 'with no parameters' do
        it { is_expected.to compile.with_all_deps }

        include_examples 'x2go packages'
        it do
          is_expected.to contain_file('/etc/sudoers.d/x2goserver')
            .that_comes_before('Sudo::Conf[bogus]')
        end

        packages = if (facts[:os]['family'] == 'RedHat') && (facts[:os]['release']['major'] == '9')
                     %w[
                       x2goagent
                       x2goclient
                       x2godesktopsharing
                       x2goserver
                       x2goserver-common
                       x2goserver-xsession
                     ]
                   else
                     %w[
                       x2goagent
                       x2goclient
                       x2goserver
                       x2goserver-common
                       x2goserver-xsession
                     ]
                   end

        packages.each do |pkg|
          it { is_expected.to contain_package(pkg) }
        end
      end
    end
  end
end
