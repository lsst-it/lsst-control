# frozen_string_literal: true

require 'spec_helper'

role = 'dm-bastion'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :sitepp do
          let(:node_params) do
            {
              role:,
              site:,
            }
          end
          let(:facts) { lsst_override_facts(os_facts) }

          it { is_expected.to compile.with_all_deps }

          include_examples('common', os_facts:, site:)
          it { is_expected.to have_nfs__client__mount_resource_count(6) }

          it do
            is_expected.to contain_nfs__client__mount('/project').with(
              share: 'project',
              server: 'nfs1.cp.lsst.org',
              atboot: true
            )
          end

          it do
            is_expected.to contain_nfs__client__mount('/scratch').with(
              share: 'scratch',
              server: 'nfs1.cp.lsst.org',
              atboot: true
            )
          end

          it do
            is_expected.to contain_nfs__client__mount('/lsstdata').with(
              share: 'lsstdata',
              server: 'nfs1.cp.lsst.org',
              atboot: true
            )
          end

          it do
            is_expected.to contain_nfs__client__mount('/readonly/lsstdata/auxtel').with(
              share: 'auxtel/lsstdata',
              server: 'nfs-auxtel.cp.lsst.org',
              atboot: true
            )
          end

          it do
            is_expected.to contain_nfs__client__mount('/repo/LATISS').with(
              share: 'auxtel/repo',
              server: 'nfs-auxtel.cp.lsst.org',
              atboot: true
            )
          end

          it do
            is_expected.to contain_nfs__client__mount('/repo/LSSTComCam').with(
              share: 'repo',
              server: 'comcam-archiver.cp.lsst.org',
              atboot: true
            )
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
