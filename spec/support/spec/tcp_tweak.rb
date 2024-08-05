# frozen_string_literal: true

shared_examples 'tcp_tweak' do
  let(:sysctl_params) do
    {
      'net.core.rmem_max' => 536_870_912,
      'net.core.wmem_max' => 536_870_912,
      'net.ipv4.tcp_rmem' => '4096 87380 536870912',
      'net.ipv4.tcp_wmem' => '4096 65536 536870912',
      'net.ipv4.tcp_congestion_control' => 'bbr',
      'net.core.default_qdisc' => 'fq',
      'net.ipv4.tcp_mtu_probing' => 1,
      'net.ipv4.tcp_slow_start_after_idle' => 0,
    }
  end

  it 'sets the correct sysctl values' do
    sysctl_params.each do |param, value|
      is_expected.to contain_sysctl__value(param).with(
        value: value,
        target: '/etc/sysctl.d/94-tcp_tweak.conf',
      )
    end
  end
end
