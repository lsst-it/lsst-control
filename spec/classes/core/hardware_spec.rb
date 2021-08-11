# frozen_string_literal: true

require 'spec_helper'

# XXX testing for classes in the catalog is not a great practice but it is
# expendent to do here as the goal is primary to test branching based on facts.
describe 'profile::core::hardware' do
  let(:node_params) do
    {
      org: 'lsst',
    }
  end

  let(:facts) do
    {
      osfamily: 'RedHat',
      operatingsystemmajrelease: '7',
    }
  end

  context 'with PowerEdge' do
    let(:facts) do
      super().merge(
        dmi: {
          product: {
            name: 'PowerEdge',
          },
        },
      )
    end

    context 'with fact has_dellperc: false' do
      let(:facts) { super().merge(has_dellperc: false) }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('ipmi') }
      it { is_expected.not_to contain_class('profile::core::perccli') }
      it { is_expected.not_to contain_class('profile::core::kernel::pcie_aspm') }
      it { is_expected.not_to contain_class('profile::core::kernel::nvme_apst') }
    end

    context 'with fact has_dellperc: true' do
      let(:facts) { super().merge(has_dellperc: true) }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('ipmi') }
      it { is_expected.to contain_class('profile::core::perccli') }
      it { is_expected.not_to contain_class('profile::core::kernel::pcie_aspm') }
      it { is_expected.not_to contain_class('profile::core::kernel::nvme_apst') }
    end
  end  # PowerEdge

  context 'with 1114S-WN10RT' do
    let(:facts) do
      super().merge(
        dmi: {
          product: {
            name: '1114S-WN10RT',
          },
        },
      )
    end

    context 'with fact has_dellperc: false' do
      let(:facts) { super().merge(has_dellperc: false) }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('ipmi') }
      it { is_expected.not_to contain_class('profile::core::perccli') }
      it { is_expected.to contain_class('profile::core::kernel::pcie_aspm') }
      it { is_expected.to contain_class('profile::core::kernel::nvme_apst') }
    end

    context 'with fact has_dellperc: true' do
      let(:facts) { super().merge(has_dellperc: true) }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('ipmi') }
      it { is_expected.not_to contain_class('profile::core::perccli') }
      it { is_expected.to contain_class('profile::core::kernel::pcie_aspm') }
      it { is_expected.to contain_class('profile::core::kernel::nvme_apst') }
    end
  end  # PowerEdge
end
