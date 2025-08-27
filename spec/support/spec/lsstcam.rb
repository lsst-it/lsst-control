# frozen_string_literal: true

shared_examples 'lsstcam-dc.cp' do
  it do
    is_expected.to contain_s3nd__instance('cp-lsstcam').with(
      image: 'ghcr.io/lsst-dm/deliverator:1.11.0',
      port: 15_571,
      volumes: [
        '/data:/data',
        '/home:/home',
      ],
      env: {
        'S3ND_ENDPOINT_URL' => 'https://s3.cp.lsst.org',
        'S3ND_QUEUE_TIMEOUT' => '15s',
        'S3ND_UPLOAD_MAX_PARALLEL' => '27',
        'S3ND_UPLOAD_PARTSIZE' => '100Mi',
        'S3ND_UPLOAD_TIMEOUT' => '3s',
        'S3ND_UPLOAD_TRIES' => '5',
      }
    )
  end

  it do
    is_expected.to contain_s3nd__instance('sdfembs3-lsstcam').with(
      image: 'ghcr.io/lsst-dm/deliverator:1.11.0',
      port: 15_581,
      volumes: [
        '/data:/data',
        '/home:/home',
      ],
      env: {
        'S3ND_ENDPOINT_URL' => 'https://sdfembs3.sdf.slac.stanford.edu',
        'S3ND_QUEUE_TIMEOUT' => '15s',
        'S3ND_UPLOAD_BWLIMIT' => '4Gi',
        'S3ND_UPLOAD_MAX_PARALLEL' => '27',
        'S3ND_UPLOAD_PARTSIZE' => '100Mi',
        'S3ND_UPLOAD_TIMEOUT' => '4s',
        'S3ND_UPLOAD_TRIES' => '3',
      }
    )
  end

  it do
    is_expected.to contain_s3nd__instance('sdfembs3-lsstcam-test').with(
      image: 'ghcr.io/lsst-dm/deliverator:1.11.0',
      port: 15_591,
      volumes: [
        '/data:/data',
        '/home:/home',
      ],
      env: {
        'S3ND_ENDPOINT_URL' => 'https://sdfembs3.sdf.slac.stanford.edu',
        'S3ND_QUEUE_TIMEOUT' => '15s',
        'S3ND_UPLOAD_BWLIMIT' => '4Gi',
        'S3ND_UPLOAD_MAX_PARALLEL' => '27',
        'S3ND_UPLOAD_PARTSIZE' => '100Mi',
        'S3ND_UPLOAD_TIMEOUT' => '4s',
        'S3ND_UPLOAD_TRIES' => '3',
      }
    )
  end
end
