# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic rke' do |facts:|
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

  if facts[:os]['family'] == 'RedHat'
    if facts[:os]['release']['major'] == '9'
      it { is_expected.not_to contain_class('network') }
      it { is_expected.to contain_class('profile::nm') }
    else
      it { is_expected.to contain_class('clustershell') }
      it { is_expected.to contain_class('network') }
      it { is_expected.not_to contain_class('profile::nm') }
    end
  end
end

role = 'rke'

describe "#{role} role" do
  alma9 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '9' }).first
  # rubocop:disable Naming/VariableNumber
  on_supported_os.merge('almalinux-9-x86_64': alma9).each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: self.class.description,
        )
      end

      let(:node_params) do
        {
          role: role,
          site: site,
        }
      end

      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :site do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts
          include_examples 'generic rke', facts: facts
        end # host
      end # lsst_sites

      context 'with antu cluster' do
        describe 'antu01.ls.lsst.org', :lhn_node, :site do
          let(:site) { 'ls' }
          let(:node_params) do
            super().merge(
              site: site,
              role: 'rke',
              cluster: 'antu',
            )
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts
          include_examples 'generic rke', facts: facts
        end
      end
    end # on os
  end # on_supported_os
end # role
