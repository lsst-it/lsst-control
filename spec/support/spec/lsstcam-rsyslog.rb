# frozen_string_literal: true

shared_examples 'lsstcam-rsyslog' do
  it { is_expected.to contain_package('rsyslog-openssl') }

  it do
    is_expected.to contain_rsyslog__component__action('fluentbit_dev').with(
      type: 'omfwd',
      facility: '*.*',
      config: {
        'target' => 'rsyslog.fluent.ayekan.dev.lsst.org',
        'port' => '5140',
        'protocol' => 'tcp',
        'StreamDriver' => 'ossl',
        'StreamDriverMode' => '1',
        'StreamDriverAuthMode' => 'anon',
      }
    )
  end
end
