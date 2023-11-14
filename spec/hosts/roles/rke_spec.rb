# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic rke' do |facts:|
  include_examples 'common', facts: facts, node_exporter: false
  include_examples 'debugutils'
  include_examples 'docker'
  include_examples 'rke profile'
  include_examples 'restic common'

  it { is_expected.to contain_class('kubectl') }
  it { is_expected.to contain_class('profile::core::rke') }
  it { is_expected.to contain_class('clustershell') }
  it { is_expected.to contain_package('make') }

  it do
    is_expected.to contain_file('/home/rke/.bashrc.d/kubectl.sh')
      .with_content(%r{^alias k='kubectl'$})
      .with_content(%r{^complete -o default -F __start_kubectl k$})
  end
end

role = 'rke'

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

      fqdn = "#{role}.tu.lsst.org"
      # rubocop:disable RSpec/RepeatedExampleGroupDescription
      describe fqdn, :sitepp do
        # rubocop:enable RSpec/RepeatedExampleGroupDescription
        override_facts(facts, fqdn: fqdn, networking: { fqdn => fqdn })
        let(:site) { 'tu' }

        it { is_expected.to compile.with_all_deps }

        include_examples 'generic rke', facts: facts

        it do
          is_expected.to contain_class('rke').with(
            version: '1.3.12',
            checksum: '579da2206aec09cadccd8d6f4818861e78a256b6ae550a229335e500a472bd50',
          )
        end
      end # host

      fqdn = "#{role}.ls.lsst.org"
      # rubocop:disable RSpec/RepeatedExampleGroupDescription
      describe fqdn, :sitepp do
        # rubocop:enable RSpec/RepeatedExampleGroupDescription
        override_facts(facts, fqdn: fqdn, networking: { fqdn => fqdn })
        let(:site) { 'ls' }

        it { is_expected.to compile.with_all_deps }

        include_examples 'generic rke', facts: facts

        it do
          is_expected.to contain_class('rke').with(
            version: '1.3.12',
            checksum: '579da2206aec09cadccd8d6f4818861e78a256b6ae550a229335e500a472bd50',
          )
        end
      end # host

      fqdn = "#{role}.cp.lsst.org"
      # rubocop:disable RSpec/RepeatedExampleGroupDescription
      describe fqdn, :sitepp do
        # rubocop:enable RSpec/RepeatedExampleGroupDescription
        override_facts(facts, fqdn: fqdn, networking: { fqdn => fqdn })
        let(:site) { 'cp' }

        it { is_expected.to compile.with_all_deps }

        include_examples 'generic rke', facts: facts

        it do
          is_expected.to contain_class('rke').with(
            version: '1.3.12',
            checksum: '579da2206aec09cadccd8d6f4818861e78a256b6ae550a229335e500a472bd50',
          )
        end
      end # host

      fqdn = "#{role}.dev.lsst.org"
      # rubocop:disable RSpec/RepeatedExampleGroupDescription
      describe fqdn, :sitepp do
        # rubocop:enable RSpec/RepeatedExampleGroupDescription
        override_facts(facts, fqdn: fqdn, networking: { fqdn => fqdn })
        let(:site) { 'dev' }

        it { is_expected.to compile.with_all_deps }

        include_examples 'generic rke', facts: facts

        it do
          is_expected.to contain_class('rke').with(
            version: '1.4.6',
            checksum: '12d8fee6f759eac64b3981ef2822353993328f2f839ac88b3739bfec0b9d818c',
          )
        end
      end # host
    end # on os
  end # on_supported_os
end # role
