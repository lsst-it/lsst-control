# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ccs::file_transfer' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with s3daemon' do
        let(:params) do
          {
            pkgurl: 'https://example.org',
            pkgurl_user: sensitive('user'),
            pkgurl_pass: sensitive('pass'),
            s3daemon: true,
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_file('/home/ccs-ipa/bin').with_ensure('directory') }

        it { is_expected.to contain_file('/home/ccs-ipa/bin/ccs-push').with_ensure('link') }
        it { is_expected.to contain_file('/home/ccs-ipa/bin/compress').with_ensure('link') }
        it { is_expected.to contain_file('/home/ccs-ipa/bin/fpack-in-place').with_ensure('link') }
        it { is_expected.to contain_file('/home/ccs-ipa/bin/push-usdf').with_ensure('link') }

        it { is_expected.to contain_file('/home/ccs-ipa/bin/mc-secret').with_mode('0600') }

        it { is_expected.to contain_file('/home/ccs-ipa/bin/fhe').with_mode('0755') }
        it { is_expected.to contain_file('/home/ccs-ipa/bin/mc').with_mode('0755') }

        it { is_expected.to contain_vcsrepo('/home/ccs-ipa/file-transfer') }

        ## s3daemon
        it { is_expected.to contain_vcsrepo('/home/ccs-ipa/s3daemon/git') }
        it { is_expected.to contain_file('/home/ccs-ipa/s3daemon/env').with_mode('0600') }

        it do
          is_expected.to contain_service('s3daemon').with(
            ensure: 'running',
            enable: true
          )
        end
      end
    end
  end
end
