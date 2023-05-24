# frozen_string_literal: true

require 'spec_helper'

role = 'dm-bastion'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:node_params) do
        {
          role: role,
          site: site,
        }
      end

      lsst_sites.each do |site|
        fqdn = "#{role}.#{site}.lsst.org"
        override_facts(facts, fqdn: fqdn, networking: { fqdn => fqdn })

        describe fqdn, :site do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts
          it { is_expected.to have_nfs__client__mount_resource_count(6) }

          it do
            is_expected.to contain_nfs__client__mount('/project').with(
              share: 'project',
              server: 'nfs1.cp.lsst.org',
              atboot: true,
            )
          end

          it do
            is_expected.to contain_nfs__client__mount('/scratch').with(
              share: 'scratch',
              server: 'nfs1.cp.lsst.org',
              atboot: true,
            )
          end

          it do
            is_expected.to contain_nfs__client__mount('/lsstdata').with(
              share: 'lsstdata',
              server: 'nfs1.cp.lsst.org',
              atboot: true,
            )
          end

          it do
            is_expected.to contain_nfs__client__mount('/readonly/lsstdata/auxtel').with(
              share: 'lsstdata',
              server: 'auxtel-archiver-1201.cp.lsst.org',
              atboot: true,
            )
          end

          it do
            is_expected.to contain_nfs__client__mount('/repo/LATISS').with(
              share: 'repo',
              server: 'auxtel-archiver-1201.cp.lsst.org',
              atboot: true,
            )
          end

          it do
            is_expected.to contain_nfs__client__mount('/repo/LSSTComCam').with(
              share: 'repo',
              server: 'comcam-archiver.cp.lsst.org',
              atboot: true,
            )
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
