# frozen_string_literal: true

shared_examples 'dhcp server' do
  it do
    is_expected.to contain_class('dhcp').with(
      interfaces: dhcp_interfaces,
      nameservers: nameservers,
      ntpservers: ntpservers,
      option_static_route: true
    )
  end
end
