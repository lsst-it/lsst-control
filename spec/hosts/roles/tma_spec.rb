# frozen_string_literal: true

require 'spec_helper'

role = 'tma'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :sitepp do
          let(:node_params) { { role:, site: } }
          let(:facts) { lsst_override_facts(os_facts) }

          it { is_expected.to compile.with_all_deps }

          include_examples 'debugutils'
          include_examples('common', os_facts:, site:)

          it { is_expected.to contain_class('profile::core::docker') }
          it { is_expected.to contain_class('profile::ts::tma') }

          %w[@base-x @xfce-desktop git git-lfs perl-File-Copy unzip].each do |pkg|
            it { is_expected.to contain_package(pkg) }
          end
        end
      end
    end
  end
end
