# frozen_string_literal: true

shared_examples 'lsstcam-dc.cp' do
  it do
    is_expected.to contain_s3daemon__instance('cp-lsstcam').with(
      image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9',
      volumes: [
        '/data:/data',
        '/home:/home',
      ],
      env: {
        'S3_ENDPOINT_URL' => 'https://s3.cp.lsst.org',
        'S3DAEMON_PORT' => 15_570,
        'S3DAEMON_HOST' => '0.0.0.0',
      }
    )
  end

  it do
    is_expected.to contain_s3daemon__instance('cp-lsstcam-s3nd').with(
      image: 'ghcr.io/lsst-dm/s3nd:1.5.2',
      volumes: [
        '/data:/data',
        '/home:/home',
      ],
      env: {
        'S3ND_ENDPOINT_URL' => 'https://s3.cp.lsst.org',
        'S3ND_PORT' => 15_571,
        'S3ND_HOST' => '',
        'S3ND_QUEUE_TIMEOUT' => '15s',
        'S3ND_UPLOAD_MAX_PARALLEL' => '27',
        'S3ND_UPLOAD_PARTSIZE' => '100Mi',
        'S3ND_UPLOAD_TIMEOUT' => '3s',
        'S3ND_UPLOAD_TRIES' => '5',
      }
    )
  end

  it do
    is_expected.to contain_s3daemon__instance('sdfembs3-lsstcam').with(
      image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9',
      volumes: [
        '/data:/data',
        '/home:/home',
      ],
      env: {
        'S3_ENDPOINT_URL' => 'https://sdfembs3.sdf.slac.stanford.edu',
        'S3DAEMON_PORT' => 15_580,
        'S3DAEMON_HOST' => '0.0.0.0',
      }
    )
  end

  it do
    is_expected.to contain_s3daemon__instance('sdfembs3-lsstcam-s3nd').with(
      image: 'ghcr.io/lsst-dm/s3nd:1.5.2',
      volumes: [
        '/data:/data',
        '/home:/home',
      ],
      env: {
        'S3ND_ENDPOINT_URL' => 'https://sdfembs3.sdf.slac.stanford.edu',
        'S3ND_PORT' => 15_581,
        'S3ND_HOST' => '',
        'S3ND_QUEUE_TIMEOUT' => '15s',
        'S3ND_UPLOAD_BWLIMIT' => '3Gi',
        'S3ND_UPLOAD_MAX_PARALLEL' => '27',
        'S3ND_UPLOAD_PARTSIZE' => '100Mi',
        'S3ND_UPLOAD_TIMEOUT' => '4s',
        'S3ND_UPLOAD_TRIES' => '3',
      }
    )
  end

  it do
    is_expected.to contain_s3daemon__instance('sdfembs3-lsstcam-test').with(
      image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9',
      volumes: [
        '/data:/data',
        '/home:/home',
      ],
      env: {
        'S3_ENDPOINT_URL' => 'https://sdfembs3.sdf.slac.stanford.edu',
        'S3DAEMON_PORT' => 15_590,
        'S3DAEMON_HOST' => '0.0.0.0',
      }
    )
  end

  it do
    is_expected.to contain_s3daemon__instance('sdfembs3-lsstcam-test-s3nd').with(
      image: 'ghcr.io/lsst-dm/s3nd:1.5.2',
      volumes: [
        '/data:/data',
        '/home:/home',
      ],
      env: {
        'S3ND_ENDPOINT_URL' => 'https://sdfembs3.sdf.slac.stanford.edu',
        'S3ND_PORT' => 15_591,
        'S3ND_HOST' => '',
        'S3ND_QUEUE_TIMEOUT' => '15s',
        'S3ND_UPLOAD_BWLIMIT' => '3Gi',
        'S3ND_UPLOAD_MAX_PARALLEL' => '27',
        'S3ND_UPLOAD_PARTSIZE' => '100Mi',
        'S3ND_UPLOAD_TIMEOUT' => '4s',
        'S3ND_UPLOAD_TRIES' => '3',
      }
    )
  end
end
