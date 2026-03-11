# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::rke' do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) do
        <<~PP
          include docker
        PP
      end

      context 'with no params' do
        it { is_expected.to compile.with_all_deps }

        it_behaves_like 'rke profile'

        it do
          is_expected.not_to contain_profile__util__keytab('rke')
            .that_requires('Class[ipa]')
        end

        it do
          is_expected.to contain_class('rke').with(
            version: '1.8.0',
            checksum: '8815da0452ae14a45566b534c48a2af6286ee73f800208ba6ec59188cb9a8d25',
          )
        end
      end

      context 'with keytab_base64 param' do
        context 'when undef' do
          let(:params) do
            {
              keytab_base64: :undef,
            }
          end

          it { is_expected.to compile.with_all_deps }

          it_behaves_like 'rke profile'

          it { is_expected.not_to contain_profile__util__keytab('rke') }
        end

        context 'when 42' do
          let(:params) do
            {
              keytab_base64: sensitive('42'),
            }
          end

          it { is_expected.to compile.with_all_deps }

          it_behaves_like 'rke profile'

          it do
            is_expected.to contain_profile__util__keytab('rke').with(
              uid: 75_500,
              keytab_base64: sensitive('42'),
            )
          end
        end
      end

      context 'with version param' do
        context 'when 1.7.6' do
          let(:params) do
            {
              version: '1.7.6',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it_behaves_like 'rke profile'

          it do
            is_expected.to contain_class('rke').with(
              version: '1.7.6',
              checksum: 'a6ef89ac3042e066b0596cb38d5bff0192b84a7d4b6ed5b14cddc4bcfd5c9cd9',
            )
          end
        end

        context 'when 1.7.7' do
          let(:params) do
            {
              version: '1.7.7',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it_behaves_like 'rke profile'

          it do
            is_expected.to contain_class('rke').with(
              version: '1.7.7',
              checksum: '4317d54ed5251d71c82b631083907c526dc74808941deebc392369108b7a4b10',
            )
          end
        end

        context 'when 1.8.0' do
          let(:params) do
            {
              version: '1.8.0',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it_behaves_like 'rke profile'

          it do
            is_expected.to contain_class('rke').with(
              version: '1.8.0',
              checksum: '8815da0452ae14a45566b534c48a2af6286ee73f800208ba6ec59188cb9a8d25',
            )
          end
        end

        context 'when 42' do
          let(:params) do
            {
              version: '42',
            }
          end

          it { is_expected.to compile.and_raise_error(%r{Unknown checksum for rke version: 42}) }
        end
      end
    end
  end
end
