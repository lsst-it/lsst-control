# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::ipa_pwd_reset' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) do
        <<~PP
          include easy_ipa
          class { 'sssd': service_names => ['sssd'] }

          service { 'httpd': }
        PP
      end

      context 'with no params' do
        let(:params) do
          {
            keytab_base64: sensitive('foo'),
            ldap_pwd: 'quix',
            ldap_user: 'baz',
            secret_key: 'bar',
          }
        end

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
