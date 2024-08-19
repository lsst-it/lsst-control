# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic rke' do |os_facts:, site:|
  include_examples 'common', os_facts: os_facts, site: site, node_exporter: false
  include_examples 'debugutils'
  include_examples 'docker'
  include_examples 'rke profile'
  include_examples 'k8snode profile'
  include_examples 'restic common'

  it do
    is_expected.to contain_class('kubectl').with(
      version: '1.28.10',
      checksum: '389c17a9700a4b01ebb055e39b8bc0886330497440dde004b5ed90f2a3a028db',
    )
  end

  it { is_expected.to contain_class('helm_binary').with_version('3.10.3') }
  it { is_expected.to contain_class('profile::core::rke') }
  it { is_expected.to contain_class('clustershell') }
  it { is_expected.to contain_package('make') }

  it do
    is_expected.to contain_file('/home/rke/.bashrc.d/kubectl.sh')
      .with_content(%r{^alias k='kubectl'$})
      .with_content(%r{^complete -o default -F __start_kubectl k$})
  end

  it do
    is_expected.to contain_restic__repository('awsrepo').with(
      backup_path: %w[
        /home/rke
        /var/lib/rook
        /etc/kubernetes
      ],
      backup_flags: '--exclude=/var/lib/rook/rook-ceph/log',
      backup_timer: '*-*-* 09:00:00',
      enable_forget: true,
      forget_timer: 'Mon..Sun 23:00:00',
      forget_flags: '--keep-last 20',
    )
  end

  case site
  when 'dev', 'tu', 'ls'
    it do
      is_expected.to contain_class('rke').with(
        version: '1.5.12',
        checksum: 'f0d1f6981edbb4c93f525ee51bc2a8ad729ba33c04f21a95f5fc86af4a7af586',
      )
    end
  else
    it do
      is_expected.to contain_class('rke').with(
        version: '1.5.10',
        checksum: 'cd5d3e8cd77f955015981751c30022cead0bd78f14216fcd1c827c6a7e5cc26e',
      )
    end
  end
end

role = 'rke'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do
        {
          role: role,
          site: site,
        }
      end

      lsst_sites.each do |site|
        fqdn = "#{role}.#{site}.lsst.org"
        describe fqdn, :sitepp do
          let(:site) { site }

          override_facts(os_facts, fqdn: fqdn, networking: { fqdn => fqdn })

          it { is_expected.to compile.with_all_deps }

          include_examples 'generic rke', os_facts: os_facts, site: site
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
