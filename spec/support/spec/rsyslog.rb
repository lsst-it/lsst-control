# frozen_string_literal: true

shared_examples 'rsyslog defaults' do |site:|
  it { is_expected.to contain_concat('/etc/rsyslog.d/50_rsyslog.conf').with_mode('0640') }
  it { is_expected.to contain_file('/etc/rsyslog.d').with_mode('0750') }

  it do
    is_expected.to contain_rsyslog__component__input('auditd').with(
      type: 'imfile',
      config: {
        'file' => '/var/log/audit/audit.log',
        'Tag' => 'auditd',
      },
    )
  end

  it do
    is_expected.to contain_rsyslog__component__action('messages').with(
      type: 'omfile',
      facility: '*.info;mail.none;authpriv.none;cron.none',
      config: {
        'file' => '/var/log/messages',
      },
    )
  end

  it do
    is_expected.to contain_rsyslog__component__action('secure').with(
      type: 'omfile',
      facility: 'authpriv.*',
      config: {
        'file' => '/var/log/secure',
      },
    )
  end

  it do
    is_expected.to contain_rsyslog__component__action('maillog').with(
      type: 'omfile',
      facility: 'mail.*',
      config: {
        'file' => '/var/log/maillog',
      },
    )
  end

  it do
    is_expected.to contain_rsyslog__component__action('cron').with(
      type: 'omfile',
      facility: 'cron.*',
      config: {
        'file' => '/var/log/cron',
      },
    )
  end

  it do
    is_expected.to contain_rsyslog__component__action('emerg').with(
      type: 'omusrmsg',
      facility: '*.emerg',
      config: {
        'users' => '*',
      },
    )
  end

  it do
    is_expected.to contain_rsyslog__component__action('boot').with(
      type: 'omfile',
      facility: 'local7.*',
      config: {
        'file' => '/var/log/boot.log',
      },
    )
  end

  case site
  when 'cp'
    it do
      is_expected.to contain_rsyslog__component__action('graylogcp').with(
        type: 'omfwd',
        facility: '*.*',
        config: {
          'Target' => 'collector.cp.lsst.org',
          'Port' => '5514',
          'Protocol' => 'udp',
        },
      )
    end
  when 'dmz', 'ls'
    it do
      is_expected.to contain_rsyslog__component__action('graylogls').with(
        type: 'omfwd',
        facility: '*.*',
        config: {
          'Target' => 'collector.ls.lsst.org',
          'Port' => '5514',
          'Protocol' => 'udp',
        },
      )
    end
  when 'dev'
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
        },
      )
    end

    it do
      is_expected.to contain_rsyslog__component__action('fluentbit_ruka').with(
        type: 'omfwd',
        facility: '*.*',
        config: {
          'target' => 'rsyslog.fluent.ruka.dev.lsst.org',
          'port' => '5140',
          'protocol' => 'tcp',
          'StreamDriver' => 'ossl',
          'StreamDriverMode' => '1',
          'StreamDriverAuthMode' => 'anon',
        },
      )
    end
  when 'tu'
    it do
      is_expected.to contain_rsyslog__component__action('graylogtu').with(
        type: 'omfwd',
        facility: '*.*',
        config: {
          'Target' => 'collector.tu.lsst.org',
          'Port' => '5514',
          'Protocol' => 'udp',
        },
      )
    end
  end
end
