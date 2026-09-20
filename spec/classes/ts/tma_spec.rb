# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ts::tma' do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9}

    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          tma_db_repo: 'git@github.com:lsst-ts/ts_tma_mariadb-docker.git',
          tma_db_path: '/opt/tma/mariadb-docker',
          pxi_0_ip:    '10.0.0.10',
          pxi_1_ip:    '10.0.0.11',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it 'enables graphical mode by default' do
        is_expected.to contain_exec('set-graphical-target')
          .with_command('/bin/systemctl set-default graphical.target')
          .with_unless('/bin/systemctl get-default | grep -q graphical.target')
          .with_onlyif('/bin/systemctl is-active sssd')
          .that_requires('Package[@base-x]')
          .that_requires('Package[@xfce-desktop]')

        is_expected.to contain_file('/etc/gdm/custom.conf')
          .with(ensure: 'file', owner: 'root', group: 'root', mode: '0644')
          .with_content(%r{WaylandEnable=false})
          .with_content(%r{DefaultSession=xfce\.desktop})
          .that_notifies('Service[gdm]')

        is_expected.to contain_service('gdm')
          .with_ensure('running')
          .with_enable(true)
          .that_requires('Exec[set-graphical-target]')
          .that_requires('Package[@xfce-desktop]')
      end

      it 'creates base TMA directory with group ownership' do
        is_expected.to contain_file('/opt/tma')
          .with(ensure: 'directory', owner: 'root', group: 'tma', mode: '0775')
      end

      it 'creates op-manager directory with group ownership' do
        is_expected.to contain_file('/opt/tma/operation-manager')
          .with(ensure: 'directory', owner: 'root', group: 'tma', mode: '2775')
      end

      it 'writes op-manager compose file and up exec' do
        is_expected.to contain_file('/opt/tma/operation-manager/docker-compose.yml')
          .with(ensure: 'file', owner: 'root', group: 'tma', mode: '0664')
          .with_content(%r{PXI_0_IP=10\.0\.0\.10})
          .with_content(%r{PXI_1_IP=10\.0\.0\.11})

        is_expected.to contain_exec('opman-up')
          .with_command(%r{docker-compose up -d})
          .with_cwd('/opt/tma/operation-manager')
          .that_subscribes_to('File[/opt/tma/operation-manager/docker-compose.yml]')
      end

      context 'when github_token is not provided' do
        it 'skips TMA DB setup' do
          is_expected.not_to contain_vcsrepo('/opt/tma/mariadb-docker')
          is_expected.to contain_notify('tma-db-skip')
            .with_message('TMA DB skip: no GitHub token')
        end

        it 'skips VIPC download' do
          is_expected.not_to contain_exec('vipc-fetch')
          is_expected.to contain_notify('vipc-skip')
            .with_message('VIPC skip: no GitHub token')
        end
      end

      context 'when github_token is provided' do
        let(:params) do
          super().merge(
            github_token: sensitive('ghp_test_token_12345')
          )
        end

        it 'manages the DB repo and backup dir with group ownership' do
          is_expected.to contain_file('/opt/tma/mariadb-docker')
            .with(ensure: 'directory', owner: 'root', group: 'tma', mode: '2775')

          is_expected.to contain_vcsrepo('/opt/tma/mariadb-docker')
            .with(
              ensure:   'present',
              provider: 'git'
            )
            .with_source(%r{^https://.*@github\.com/lsst-ts/ts_tma_mariadb-docker\.git$})

          is_expected.to contain_file('/opt/tma/mariadb-docker/backup')
            .with(ensure: 'directory', owner: 'root', group: 'tma', mode: '2775')
        end

        it 'configures backup cron jobs to run as root' do
          is_expected.to contain_cron('tma-db-createbackup')
            .with_user('root')
            .with_command(%r{/opt/tma/mariadb-docker/createbackup\.pl})

          is_expected.to contain_cron('tma-db-python-backup')
            .with_user('root')
        end

        it 'downloads VIPC file using GitHub token' do
          is_expected.to contain_exec('vipc-fetch')
            .with_command(%r{Authorization: token})
            .with_creates('/usr/local/JKI/VIPM/LSST_tma_dependencies.vipc')
        end
      end

      it 'creates LabVIEW yum repository' do
        is_expected.to contain_yumrepo('ni-labview-2024-el9-pro')
          .with(
            ensure: 'present',
            baseurl: 'https://download.ni.com/ni-linux-desktop/LabVIEW/2024/Q3/f2/pro/rpm/ni-labview-2024/el9',
            enabled: 1,
            gpgcheck: 0,
            repo_gpgcheck: 0
          )
          .that_comes_before('Package[ni-labview-2024-pro]')
      end

      it 'installs LabVIEW Pro package from the repository' do
        is_expected.to contain_package('ni-labview-2024-pro')
          .with_ensure('24.3.2.49152-0+f0')
      end

      it 'creates JKI directories for VIPM installation' do
        ['/usr/local/JKI', '/etc/JKI'].each do |dir|
          is_expected.to contain_file(dir)
            .with(ensure: 'directory', owner: 0, group: 0, mode: '0755')
        end

        is_expected.to contain_file('/usr/local/JKI/VIPM')
          .with(ensure: 'directory', owner: 0, group: 0, mode: '0755')
          .that_requires('File[/usr/local/JKI]')
      end

      context 'when enable_graphical => false' do
        let(:params) do
          super().merge(
            enable_graphical: false
          )
        end

        it 'does not configure graphical mode' do
          is_expected.not_to contain_exec('set-graphical-target')
          is_expected.not_to contain_file('/etc/gdm/custom.conf')
          is_expected.not_to contain_service('gdm')
        end
      end

      context 'when vipm_url => undef' do
        let(:params) do
          super().merge(
            vipm_url: :undef
          )
        end

        it 'does not manage VIPM download or unzip' do
          is_expected.not_to contain_exec('vipm-download')
          is_expected.not_to contain_exec('vipm-unzip')
        end
      end

      context 'when vipm_url is provided' do
        let(:params) do
          super().merge(
            vipm_url: 'https://repo-nexus.lsst.org/nexus/repository/tma_artifacts/labview/vipm-22.1.2354-linux.zip'
          )
        end

        it 'downloads and unpacks VIPM into vipm_root' do
          is_expected.to contain_exec('vipm-download')
            .with_command(%r{curl -fsSL -o /tmp/vipm\.zip https://repo-nexus\.lsst\.org/})
            .with_unless(%r{test -x /usr/local/JKI/VIPM/vipm})
            .that_requires('File[/usr/local/JKI/VIPM]')

          is_expected.to contain_exec('vipm-unzip')
            .with_command(%r{unzip -o /tmp/vipm\.zip -d /usr/local/JKI/VIPM})
            .with_unless(%r{test -x /usr/local/JKI/VIPM/vipm})
            .that_requires('Exec[vipm-download]')
        end
      end
    end
  end
end
