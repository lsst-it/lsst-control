# frozen_string_literal: true

require 'spec_helper'

FOREMAN_VERSION = '3.2.1'
PUPPETSERVER_VERSION = '6.19.0'
TERMINI_VERSION = '6.19.1'

describe 'test1.dev.lsst.org' do
  describe 'foreman role' do
    lsst_sites.each do |site|
      context "with site #{site}", :site, :common do
        let(:node_params) do
          {
            site: site,
            role: 'foreman',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('profile::core::puppet_master') }

        include_examples 'debugutils'

        it do
          is_expected.to contain_class('foreman').with(
            version: FOREMAN_VERSION,
          )
        end

        it do
          is_expected.to contain_class('foreman::repo').with(
            repo: '3.2',
          )
        end

        it { is_expected.to contain_foreman__plugin('puppet') }
        it { is_expected.to contain_foreman__cli__plugin('foreman_puppet') }
        it { is_expected.to contain_foreman__plugin('tasks') }
        it { is_expected.to contain_foreman__plugin('remote_execution') }

        [
          "0:foreman-cli-#{FOREMAN_VERSION}-1.el7.noarch",
          "0:foreman-debug-#{FOREMAN_VERSION}-1.el7.noarch",
          "0:foreman-dynflow-sidekiq-#{FOREMAN_VERSION}-1.el7.noarch",
          "0:foreman-#{FOREMAN_VERSION}-1.el7.noarch",
          "0:foreman-libvirt-#{FOREMAN_VERSION}-1.el7.noarch",
          "0:foreman-postgresql-#{FOREMAN_VERSION}-1.el7.noarch",
          "0:foreman-service-#{FOREMAN_VERSION}-1.el7.noarch",
          "0:puppetdb-termini-#{TERMINI_VERSION}-1.el7.noarch",
          "0:puppetserver-#{PUPPETSERVER_VERSION}-1.el7.noarch",
          "1:foreman-installer-#{FOREMAN_VERSION}-1.el7.noarch",
          "0:foreman-proxy-#{FOREMAN_VERSION}-1.el7.noarch",
          "0:foreman-vmware-#{FOREMAN_VERSION}-1.el7.noarch",
        ].each do |pkg|
          it { is_expected.to contain_yum__versionlock(pkg) }
        end

        it { is_expected.to contain_class('puppetdb::globals').with_version(TERMINI_VERSION) }

        it do
          is_expected.to contain_class('puppet').with(
            server_puppetserver_version: PUPPETSERVER_VERSION,
            server_version: PUPPETSERVER_VERSION,
          )
        end
      end
    end # site
  end # role
end
