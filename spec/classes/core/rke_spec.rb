# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::rke' do
  let(:node_params) { { org: 'lsst' } }

  context 'with no params' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.not_to contain_class('cni::plugins') }
    it { is_expected.not_to contain_class('cni::plugins::dhcp') }
    it { is_expected.not_to contain_profile__util__keytab('rke') }
    it { is_expected.to contain_vcsrepo('/home/rke/k8s-cookbook') }

    it do
      is_expected.to contain_class('rke').with(
        version: '1.3.3',
        checksum: '61088847d80292f305e233b7dff4ac8e47fefdd726e5245052450bf05da844aa',
      )
    end
  end

  context 'with enable_dhcp param' do
    context 'when false' do
      let(:params) do
        {
          enable_dhcp: false,
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.not_to contain_class('cni::plugins') }
      it { is_expected.not_to contain_class('cni::plugins::dhcp') }
    end

    context 'when true' do
      let(:params) do
        {
          enable_dhcp: true,
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('cni::plugins') }
      it { is_expected.to contain_class('cni::plugins::dhcp') }
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

      it { is_expected.not_to contain_profile__util__keytab('rke') }
    end

    context 'when 42' do
      let(:params) do
        {
          keytab_base64: '42',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_profile__util__keytab('rke').with(
          uid: 75_500,
          keytab_base64: '42',
        )
      end
    end
  end

  context 'with version param' do
    context 'when 1.3.3' do
      let(:params) do
        {
          version: '1.3.3',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_class('rke').with(
          version: '1.3.3',
          checksum: '61088847d80292f305e233b7dff4ac8e47fefdd726e5245052450bf05da844aa',
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
