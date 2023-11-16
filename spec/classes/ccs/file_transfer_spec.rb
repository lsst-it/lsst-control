# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ccs::file_transfer' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with param install => true' do
        let(:params) do
          {
            install: true,
            pkgurl: 'https://example.org',
            pkgurl_user: 'user',
            pkgurl_pass: 'pass',
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
      end
    end
  end
end
