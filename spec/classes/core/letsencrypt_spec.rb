# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::letsencrypt' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with no params' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('letsencrypt') }
        it { is_expected.to contain_class('letsencrypt::plugin::dns_route53') }

        it do
          is_expected.to contain_yum__versionlock('python-s3transfer').with(
            ensure: 'present',
            version: '0.1.13',
            release: '1.el7.0.1',
            arch: 'noarch',
          ).that_comes_before('Class[letsencrypt::plugin::dns_route53]')
                                                                      .that_comes_before('Package[python-s3transfer]')
        end

        it { is_expected.to contain_package('python-s3transfer') }

        if os_facts[:os]['name'] == 'CentOS'
          it { is_expected.to contain_package('python2-futures.noarch') }
        end

        it { is_expected.to have_letsencrypt__certonly_resource_count(0) }
        it { is_expected.not_to contain_file('/root/.aws') }
        it { is_expected.not_to contain_file('/root/.aws/credentials') }
      end

      context 'with certonly param' do
        let(:params) do
          {
            certonly: {
              'foo' => {
                'plugin' => 'dns-route53',
                'manage_cron' => true,
              },
              'bar' => {
                'plugin' => 'dns-route53',
                'manage_cron' => false,
              },
            },
          }
        end

        it do
          is_expected.to contain_letsencrypt__certonly('foo').with(
            plugin: 'dns-route53',
            manage_cron: true,
          )
        end

        it do
          is_expected.to contain_letsencrypt__certonly('bar').with(
            plugin: 'dns-route53',
            manage_cron: false,
          )
        end
      end

      context 'with aws_credentials param' do
        let(:params) do
          {
            aws_credentials: sensitive('foo'),
          }
        end

        it do
          is_expected.to contain_file('/root/.aws').with(
            ensure: 'directory',
            mode: '0700',
            backup: false,
          )
        end

        it do
          is_expected.to contain_file('/root/.aws/credentials').with(
            ensure: 'file',
            mode: '0600',
            backup: false,
            content: 'foo',
          )
        end
      end
    end
  end
end
