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

        include_examples 'rke profile'

        it do
          is_expected.not_to contain_profile__util__keytab('rke')
            .that_requires('Class[ipa]')
        end

        it do
          is_expected.to contain_class('rke').with(
            version: '1.7.8',
            checksum: '9494448f684ab0f3f79c62aa9736cd718743ad94e78a291f49eafec8bc71abde'
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

          include_examples 'rke profile'

          it { is_expected.not_to contain_profile__util__keytab('rke') }
        end

        context 'when 42' do
          let(:params) do
            {
              keytab_base64: sensitive('42'),
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'rke profile'

          it do
            is_expected.to contain_profile__util__keytab('rke').with(
              uid: 75_500,
              keytab_base64: sensitive('42')
            )
          end
        end
      end

      context 'with version param' do
        context 'when 1.6.5' do
          let(:params) do
            {
              version: '1.6.5',
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'rke profile'

          it do
            is_expected.to contain_class('rke').with(
              version: '1.6.5',
              checksum: '80694373496abd5033cb97c2512f2c36c933d301179881e1d28bf7b78efab3e7'
            )
          end
        end

        context 'when 1.7.6' do
          let(:params) do
            {
              version: '1.7.6',
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'rke profile'

          it do
            is_expected.to contain_class('rke').with(
              version: '1.7.6',
              checksum: 'a6ef89ac3042e066b0596cb38d5bff0192b84a7d4b6ed5b14cddc4bcfd5c9cd9'
            )
          end
        end

        context 'when 1.7.8' do
          let(:params) do
            {
              version: '1.7.8',
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'rke profile'

          it do
            is_expected.to contain_class('rke').with(
              version: '1.7.8',
              checksum: '9494448f684ab0f3f79c62aa9736cd718743ad94e78a291f49eafec8bc71abde'
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
