# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic rke' do
  include_examples 'debugutils'
  include_examples 'docker'
  include_examples 'rke profile'

  it { is_expected.to contain_class('kubectl') }
  it { is_expected.to contain_class('profile::core::rke') }
  it { is_expected.to contain_class('clustershell') }

  it do
    is_expected.to contain_file('/home/rke/.bashrc.d/kubectl.sh')
      .with_content(%r{^alias k='kubectl'$})
      .with_content(%r{^complete -o default -F __start_kubectl k$})
  end
end

role = 'rke'

describe "#{role} role" do
  alma9 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '9' }).first
  # rubocop:disable Naming/VariableNumber
  on_supported_os.merge('almalinux-9-x86_64': alma9).each do |os, facts|
    # rubocop:enable Naming/VariableNumber
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

        describe fqdn, :sitepp do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts
          include_examples 'generic rke'
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
