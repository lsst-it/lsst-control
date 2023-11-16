# frozen_string_literal: true

require 'spec_helper'

# XXX testing for classes in the catalog is not a great practice but it is
# expendent to do here as the goal is primary to test branching based on facts.
describe 'profile::core::hardware' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

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

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('ipmi') }
        it { is_expected.not_to contain_class('profile::core::kernel::pcie_aspm') }
        it { is_expected.not_to contain_class('profile::core::kernel::nvme_apst') }
        it { is_expected.not_to contain_profile__util__kernel_param('pci=pcie_bus_perf') }

        context 'with fact has_dellperc: false' do
          let(:facts) { super().merge(has_dellperc: false) }

          it { is_expected.not_to contain_class('profile::core::perccli') }
        end

        context 'with fact has_dellperc: true' do
          let(:facts) { super().merge(has_dellperc: true) }

          it { is_expected.to contain_class('profile::core::perccli') }
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

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('ipmi') }

        if (os_facts[:os]['family'] == 'RedHat') && (os_facts[:os]['release']['major'] == '7')
          it { is_expected.to contain_class('profile::core::kernel::pcie_aspm') }
          it { is_expected.to contain_class('profile::core::kernel::nvme_apst') }

          it do
            is_expected.to contain_profile__util__kernel_param('pci=pcie_bus_perf')
              .with_reboot(false)
          end
        else
          it { is_expected.not_to contain_class('profile::core::kernel::pcie_aspm') }
          it { is_expected.not_to contain_class('profile::core::kernel::nvme_apst') }
          it { is_expected.not_to contain_profile__util__kernel_param('pci=pcie_bus_perf') }
        end
      end  # 1114S-WN10RT

      context 'with H12SSL-NT' do
        let(:facts) do
          super().merge(
            dmi: {
              board: {
                product: 'H12SSL-NT',
              },
            },
          )
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('ipmi') }
        it { is_expected.not_to contain_class('profile::core::perccli') }
        it { is_expected.not_to contain_class('profile::core::kernel::pcie_aspm') }
        it { is_expected.not_to contain_class('profile::core::kernel::nvme_apst') }
        it { is_expected.not_to contain_profile__util__kernel_param('pci=pcie_bus_perf') }
      end  # H12SSL-NT

      context 'with SSG-640SP-E1CR90' do
        let(:facts) do
          super().merge(
            dmi: {
              product: {
                name: 'SSG-640SP-E1CR90',
              },
            },
          )
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('ipmi') }
      end  # SSG-640SP-E1CR90
    end
  end
end
