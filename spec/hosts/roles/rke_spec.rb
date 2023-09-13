# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic rke' do
  include_examples 'debugutils'
  include_examples 'docker'
  include_examples 'rke profile'

  it { is_expected.to contain_class('kubectl') }
  it { is_expected.to contain_class('profile::core::rke') }
  it { is_expected.to contain_class('clustershell') }
  it { is_expected.to contain_class('restic') }

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

      fqdn = "#{role}.tu.lsst.org"
      # rubocop:disable RSpec/RepeatedExampleGroupDescription
      describe fqdn, :sitepp do
        # rubocop:enable RSpec/RepeatedExampleGroupDescription
        override_facts(facts, fqdn: fqdn, networking: { fqdn => fqdn })
        let(:site) { 'tu' }

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_class('rke').with(
            version: '1.3.12',
            checksum: '579da2206aec09cadccd8d6f4818861e78a256b6ae550a229335e500a472bd50',
          )
        end

        include_examples 'common', facts: facts
        include_examples 'generic rke'
      end # host

      fqdn = "#{role}.ls.lsst.org"
      # rubocop:disable RSpec/RepeatedExampleGroupDescription
      describe fqdn, :sitepp do
        # rubocop:enable RSpec/RepeatedExampleGroupDescription
        override_facts(facts, fqdn: fqdn, networking: { fqdn => fqdn })
        let(:site) { 'ls' }

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_class('rke').with(
            version: '1.3.12',
            checksum: '579da2206aec09cadccd8d6f4818861e78a256b6ae550a229335e500a472bd50',
          )
        end

        include_examples 'common', facts: facts
        include_examples 'generic rke'
      end # host

      fqdn = "#{role}.cp.lsst.org"
      # rubocop:disable RSpec/RepeatedExampleGroupDescription
      describe fqdn, :sitepp do
        # rubocop:enable RSpec/RepeatedExampleGroupDescription
        override_facts(facts, fqdn: fqdn, networking: { fqdn => fqdn })
        let(:site) { 'cp' }

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_class('rke').with(
            version: '1.3.12',
            checksum: '579da2206aec09cadccd8d6f4818861e78a256b6ae550a229335e500a472bd50',
          )
        end

        include_examples 'common', facts: facts
        include_examples 'generic rke'
      end # host

      fqdn = "#{role}.dev.lsst.org"
      # rubocop:disable RSpec/RepeatedExampleGroupDescription
      describe fqdn, :sitepp do
        # rubocop:enable RSpec/RepeatedExampleGroupDescription
        override_facts(facts, fqdn: fqdn, networking: { fqdn => fqdn })
        let(:site) { 'dev' }

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_class('rke').with(
            version: '1.4.6-rc4',
            checksum: '220cdd575fcefc77ef8d7c2ff030cb8604fa484f7db5d3bcffa2cd6c794b2563',
          )
        end

        include_examples 'common', facts: facts
        include_examples 'generic rke'
      end # host
    end # on os
  end # on_supported_os
end # role
