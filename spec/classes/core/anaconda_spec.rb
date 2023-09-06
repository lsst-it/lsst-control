# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::anaconda' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with params' do
        let(:params) do
          {
            anaconda_version: 'quux',
            python_env_name: 'foo',
            python_env_version: 'bar',
            conda_packages: {
              'baz' => {
                'channel' => 'qux',
                'version' => 'corge',
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_exec('create_conda_env').with(
            'command' => '/opt/anaconda/bin/conda create -y --name foo python=bar',
          )
        }

        it {
          is_expected.to contain_exec('install_baz_via_conda').with(
            'command' => 'conda install -y -n foo -c qux baz=corge',
          )
        }

        it {
          is_expected.to contain_exec('install_anaconda').with(
            'command' => '/bin/wget https://repo.anaconda.com/archive/quux-Linux-x86_64.sh -O /tmp/anaconda_installer.sh && /bin/bash /tmp/anaconda_installer.sh -b -p /opt/anaconda',
          )
        }

        it {
          is_expected.to contain_exec('install_libmamba_env').with(
            'command' => '/opt/anaconda/bin/conda install -y -n foo conda-libmamba-solver',
          )
        }

        it {
          is_expected.to contain_exec('set_libmamba').with(
            'command' => 'conda config --set solver libmamba',
          )
        }

        it {
          is_expected.to contain_file('/etc/profile.d/conda_source.sh').with(
            'ensure' => 'file',
            'mode' => '0644',
            'content' => 'source /opt/anaconda/bin/activate foo',
          )
        }

        it {
          is_expected.to contain_package('wget').with(
            'ensure' => 'installed',
          )
        }
      end
    end
  end
end
