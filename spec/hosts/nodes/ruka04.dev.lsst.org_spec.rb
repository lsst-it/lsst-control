# frozen_string_literal: true

require 'spec_helper'

#
# primarily testing cluster/ruka/variant/r430; for ruka cluster layer spec see
# ruka01.dev.lsst.org.yaml
#
describe 'ruka04.dev.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
                       fqdn: 'ruka04.dev.lsst.org',
                       is_virtual: false,
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R430',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'rke',
          site: 'dev',
          cluster: 'ruka',
          variant: 'r430',
        }
      end
      let(:vlan_id) { 2505 }

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      if facts[:os]['release']['major'] == '7'
        it do
          is_expected.to contain_network__interface('em1').with(
            bootproto: 'none',
            onboot: 'no',
            type: 'Ethernet',
          )
        end

        it do
          is_expected.to contain_network__interface('p1p1').with(
            bootproto: 'dhcp',
            defroute: 'yes',
            onboot: 'yes',
            type: 'Ethernet',
          )
        end

        it do
          is_expected.to contain_network__interface('p1p2').with(
            bootproto: 'none',
            onboot: 'no',
            type: 'Ethernet',
          )
        end

        it do
          is_expected.to contain_network__interface("p1p2.#{vlan_id}").with(
            bootproto: 'none',
            defroute: 'no',
            nozeroconf: 'yes',
            onboot: 'yes',
            type: 'none',
            vlan: 'yes',
            bridge: "br#{vlan_id}",
          )
        end
      else
        include_context 'with nm interface'

        it { is_expected.to have_nm__connection_resource_count(4) }

        %w[
          eno1
          eno2
          eno3
          eno4
        ].each do |i|
          context "with #{i}" do
            let(:interface) { i }

            it_behaves_like 'nm disabled interface'
          end
        end
      end
    end # on os
  end # on_supported_os
end
