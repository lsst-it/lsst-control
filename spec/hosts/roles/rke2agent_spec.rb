# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic rke2agent' do |os_facts:, site:|
  it_behaves_like 'common', os_facts:, site:, node_exporter: false
  it_behaves_like 'debugutils'
  it_behaves_like 'k8snode profile'
  it_behaves_like 'restic common'

  it do
    is_expected.to contain_class('rke2').with(
      node_type: 'agent',
      release_series: '1.33',
      version: '1.33.4~rke2r1',
      versionlock: true,
    )
  end

  it { expect(catalogue.resource('class', 'rke2')[:config]).to include('node-name') }
  it { expect(catalogue.resource('class', 'rke2')[:config]).to include('tls-san') }

  it do
    expect(catalogue.resource('class', 'rke2')[:config]).to include(
      'disable' => %w[
        rke2-ingress-nginx
        rke2-snapshot-controller
        rke2-snapshot-controller-crd
        rke2-snapshot-validation-webhook
      ],
    )
  end

  it do
    expect(catalogue.resource('class', 'rke2')[:config]).to include(
      'disable-cloud-controller' => true,
    )
  end

  it { is_expected.to contain_class('clustershell') }

  it do
    is_expected.to contain_restic__repository('awsrepo').with(
      backup_path: %w[
        /etc/cni
        /etc/rancher
        /var/lib/rancher/rke2
        /var/lib/rook
      ],
      backup_flags: %w[
        --exclude=/var/lib/rancher/rke2/agent/containerd
        --exclude=/var/lib/rancher/rke2/agent/logs
        --exclude=/var/lib/rook/rook-ceph/log
      ],
      backup_timer: '*-*-* 09:00:00',
      enable_forget: true,
      forget_timer: 'Mon..Sun 23:00:00',
      forget_flags: '--keep-last 20',
    )
  end

  it do
    is_expected.to contain_grubby__kernel_opt('rootflags=pquota').with(
      ensure: 'absent',
    )
  end
end

role = 'rke2agent'

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

          it_behaves_like 'generic rke2agent', os_facts:, site:
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
