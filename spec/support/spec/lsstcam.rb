# frozen_string_literal: true

shared_examples 'lsstcam-dc.cp' do
  it do
    is_expected.to contain_s3daemon__instance('cp-lsstcam').with(
      image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9',
      env: {
        'S3_ENDPOINT_URL' => 'https://s3.cp.lsst.org',
        'S3DAEMON_PORT' => 15_570,
      }
    )
  end

  it do
    is_expected.to contain_s3daemon__instance('sdfembs3-lsstcam').with(
      image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9',
      env: {
        'S3_ENDPOINT_URL' => 'https://sdfembs3.sdf.slac.stanford.edu',
        'S3DAEMON_PORT' => 15_580,
      }
    )
  end
end
