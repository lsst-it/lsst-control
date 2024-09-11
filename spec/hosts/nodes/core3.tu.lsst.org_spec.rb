# frozen_string_literal: true

require 'spec_helper'

describe 'core3.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'PowerEdge R440',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'hypervisor',
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples('baremetal',
                       bmc: {
                         lan1: {
                           ip: '140.252.146.140',
                           netmask: '255.255.255.192',
                           gateway: '140.252.146.129',
                           type: 'static',
                         },
                       })
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(8) }

      %w[
        em2
        p2p1
        p2p2
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with em1' do
        let(:interface) { 'em1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('140.252.146.70/27,140.252.146.65') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('140.252.146.71;140.252.146.72;140.252.146.73') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('tu.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end

      context 'with p2p1.3040' do
        let(:interface) { 'p2p1.3040' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 3040, parent: 'p2p1'
        it_behaves_like 'nm bridge slave interface', master: 'br3040'
      end

      context 'with p2p1.3085' do
        let(:interface) { 'p2p1.3085' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 3085, parent: 'p2p1'
        it_behaves_like 'nm bridge slave interface', master: 'br3085'
      end

      context 'with br3040' do
        let(:interface) { 'br3040' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm no-ip interface'
        it_behaves_like 'nm bridge interface'
      end

      context 'with br3085' do
        let(:interface) { 'br3085' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm no-ip interface'
        it_behaves_like 'nm bridge interface'
      end
    end # on os
  end # on_supported_os
end
