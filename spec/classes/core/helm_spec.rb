# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::helm' do
  context 'with no params' do
    it { is_expected.to compile.with_all_deps }

    it do
      is_expected.to contain_class('helm_binary').with(
        version: '3.5.4',
        checksum: 'a8ddb4e30435b5fd45308ecce5eaad676d64a5de9c89660b56face3fe990b318'
      )
    end
  end

  context 'with version param' do
    context 'when 3.6.3' do
      let(:params) do
        {
          version: '3.6.3',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_class('helm_binary').with(
          version: '3.6.3',
          checksum: '07c100849925623dc1913209cd1a30f0a9b80a5b4d6ff2153c609d11b043e262'
        )
      end
    end

    context 'when 42' do
      let(:params) do
        {
          version: '42',
        }
      end

      it { is_expected.to compile.and_raise_error(%r{Unknown checksum for helm version: 42}) }
    end
  end
end
