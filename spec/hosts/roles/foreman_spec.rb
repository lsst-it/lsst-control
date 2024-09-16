# frozen_string_literal: true

require 'spec_helper'

role = 'foreman'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    next unless os =~ (%r{^centos-7-x86_64$}) || os =~ (%r{^almalinux-8-x86_64$})

    context "on #{os}" do
      let(:node_params) do
        {
          role:,
          site:,
        }
      end
      let(:smee_url) { 'https://smee.io/lpxrggGObEn5YTA' }

      describe 'foreman.dev.lsst.org', :sitepp do
        site = 'dev'
        let(:site) { site }
        let(:facts) { lsst_override_facts(os_facts) }
        let(:ntpservers) do
          %w[
            ntp.shoa.cl
            ntp.cp.lsst.org
            1.cl.pool.ntp.org
            1.south-america.pool.ntp.org
          ]
        end
        let(:ignore_branch_prefixes) do
          %w[
            master
            ncsa_production
            disable
            core
            cp
            dev
            ls
            tu
          ]
        end

        it { is_expected.to compile.with_all_deps }

        include_examples('common', os_facts:, site:)
        include_examples 'generic foreman'
      end # host

      describe 'foreman.tuc.lsst.cloud', :sitepp do
        site = 'tu'
        let(:site) { site }
        let(:facts) { lsst_override_facts(os_facts) }
        let(:ntpservers) do
          %w[
            140.252.1.140
            140.252.1.141
            140.252.1.142
          ]
        end
        let(:ignore_branch_prefixes) do
          %w[
            master
            ncsa_production
            disable
            core
            cp
            dev
            ls
            tu
          ]
        end

        it { is_expected.to compile.with_all_deps }

        include_examples('common', os_facts:, site:)
        include_examples 'generic foreman'
      end # host

      describe 'foreman.ls.lsst.org', :sitepp do
        site = 'ls'
        let(:site) { site }
        let(:facts) { lsst_override_facts(os_facts) }
        let(:ntpservers) do
          %w[
            ntp.shoa.cl
            ntp.cp.lsst.org
            1.cl.pool.ntp.org
            1.south-america.pool.ntp.org
          ]
        end
        let(:ignore_branch_prefixes) do
          %w[
            master
            ncsa_production
            disable
            core
            cp
            dev
            ls
            tu
          ]
        end

        it { is_expected.to compile.with_all_deps }

        include_examples('common', os_facts:, site:)
        include_examples 'generic foreman'
      end # host

      describe 'foreman.cp.lsst.org', :sitepp do
        site = 'cp'
        let(:site) { site }
        let(:facts) { lsst_override_facts(os_facts) }
        let(:ntpservers) do
          %w[
            ntp.cp.lsst.org
            ntp.shoa.cl
            1.cl.pool.ntp.org
            1.south-america.pool.ntp.org
          ]
        end
        let(:ignore_branch_prefixes) do
          %w[
            master
            ncsa_production
            disable
            core
            dev
            ls
            tu
          ]
        end

        it { is_expected.to compile.with_all_deps }

        include_examples('common', os_facts:, site:)
        include_examples 'generic foreman'
      end # host
    end
  end
end
