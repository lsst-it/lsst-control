# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ccs::sal_dx' do
  let(:node_params) { { org: 'lsst' } }

  context 'with no params' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_yumrepo('lsst-ts-private') }

    it do
      is_expected.to contain_package('OpenSpliceDDS-6.10.4-6.el7')
        .that_requires('Yumrepo[lsst-ts-private]')
    end
  end
end
