# frozen_string_literal: true

shared_examples 'rsyslog defaults' do
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
        'file' => '-/var/log/maillog',
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

  it do
    case site  # XXX this is super ugly, we may need to pass in site as a param
    when 'cp'
      is_expected.to contain_rsyslog__component__action('graylogcp').with(
        type: 'omfwd',
        facility: '*.*',
        config: {
          'Target' => 'collector.cp.lsst.org',
          'Port' => '5514',
          'Protocol' => 'udp',
        },
      )
    when 'dev', 'dmz', 'ls'
      is_expected.to contain_rsyslog__component__action('graylogls').with(
        type: 'omfwd',
        facility: '*.*',
        config: {
          'Target' => 'collector.ls.lsst.org',
          'Port' => '5514',
          'Protocol' => 'udp',
        },
      )
    when 'tu'
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
