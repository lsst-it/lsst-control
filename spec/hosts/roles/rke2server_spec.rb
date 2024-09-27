# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic rke2server' do |os_facts:, site:|
  include_examples 'common', os_facts:, site:, node_exporter: false
  include_examples 'debugutils'
  include_examples 'k8snode profile'
  include_examples 'restic common'

  case site
  when 'dev'
    it do
      is_expected.to contain_class('rke2').with(
        node_type: 'server',
        release_series: '1.29',
        version: '1.29.9~rke2r1',
        versionlock: true
      )
    end
  else
    it do
      is_expected.to contain_class('rke2').with(
        node_type: 'server',
        release_series: '1.28',
        version: '1.28.12~rke2r1',
        versionlock: true
      )
    end
  end

  it { expect(catalogue.resource('class', 'rke2')[:config]).to include('server') }
  it { expect(catalogue.resource('class', 'rke2')[:config]).to include('node-name') }
  it { expect(catalogue.resource('class', 'rke2')[:config]).to include('tls-san') }

  it do
    expect(catalogue.resource('class', 'rke2')[:config]).to include(
      'disable' => ['rke2-ingress-nginx']
    )
  end

  it do
    expect(catalogue.resource('class', 'rke2')[:config]).to include(
      'disable-cloud-controller' => true
    )
  end

  it { is_expected.to contain_class('helm_binary').with_version('3.10.3') }
  it { is_expected.to contain_class('clustershell') }

  it do
    is_expected.to contain_accounts__user('rke2').with(
      uid: '61616',
      gid: '61616'
    )
  end

  it do
    is_expected.to contain_file('/home/rke2/.bashrc.d/kubectl.sh')
      .with_content(%r{^alias k='kubectl'$})
      .with_content(%r{^complete -o default -F __start_kubectl k$})
  end

  it do
    is_expected.to contain_restic__repository('awsrepo').with(
      backup_path: %w[
        /etc/cni
        /etc/rancher
        /var/lib/rancher/rke2/server/db/snapshots
        /var/lib/rook
      ],
      backup_flags: '--exclude=/var/lib/rook/rook-ceph/log',
      backup_timer: '*-*-* 09:00:00',
      enable_forget: true,
      forget_timer: 'Mon..Sun 23:00:00',
      forget_flags: '--keep-last 20'
    )
  end

  it do
    is_expected.to contain_grubby__kernel_opt('rootflags=pquota').with(
      ensure: 'absent'
    )
  end
end

role = 'rke2server'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

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

          include_examples 'generic rke2server', os_facts:, site:
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
