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
            version: '1.5.10',
            checksum: 'cd5d3e8cd77f955015981751c30022cead0bd78f14216fcd1c827c6a7e5cc26e',
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
              keytab_base64: sensitive('42'),
            )
          end
        end
      end

      context 'with version param' do
        context 'when 1.5.8' do
          let(:params) do
            {
              version: '1.5.8',
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'rke profile'

          it do
            is_expected.to contain_class('rke').with(
              version: '1.5.8',
              checksum: 'f691a33b59db48485e819d89773f2d634e347e9197f4bb6b03270b192bd9786d',
            )
          end
        end

        context 'when 1.5.9' do
          let(:params) do
            {
              version: '1.5.9',
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'rke profile'

          it do
            is_expected.to contain_class('rke').with(
              version: '1.5.9',
              checksum: '1d31248135c2d0ef0c3606313d80bd27a199b98567a053036b9e49e13827f54b',
            )
          end
        end

        context 'when 1.5.10' do
          let(:params) do
            {
              version: '1.5.10',
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'rke profile'

          it do
            is_expected.to contain_class('rke').with(
              version: '1.5.10',
              checksum: 'cd5d3e8cd77f955015981751c30022cead0bd78f14216fcd1c827c6a7e5cc26e',
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
