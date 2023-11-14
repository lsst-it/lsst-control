# frozen_string_literal: true

shared_examples 'telegraf' do
  it do
    is_expected.to contain_class('telegraf').with_outputs(
      'http' => [{
        'url' => 'https://mimir.o11y.dev.lsst.org/api/v1/push',
        'data_format' => 'prometheusremotewrite',
        'headers' => {
          'Content-Type' => 'application/x-protobuf',
          'Content-Encoding' => 'snappy',
          'X-Prometheus-Remote-Write-Version' => '0.1.0',
        },
      }],
    )
  end

  it { is_expected.to contain_file('/etc/telegraf/telegraf.d').with_purge(true) }
end
