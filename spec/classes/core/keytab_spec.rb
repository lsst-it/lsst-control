# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::keytab' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with no parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_profile__util__keytab_resource_count(0) }
      end

      context 'with keytab param' do
        let(:params) do
          {
            keytab: {
              foo: {
                uid: 1234,
                keytab_base64: sensitive('Zm9v'),
              },
            },
          }
        end

        it { is_expected.to have_profile__util__keytab_resource_count(1) }

        it do
          is_expected.to contain_profile__util__keytab('foo').with(
            uid: 1234,
            keytab_base64: sensitive('Zm9v'),
          )
        end
      end
    end
  end
end
