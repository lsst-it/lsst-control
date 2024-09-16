# frozen_string_literal: true

shared_examples 's3daemon' do
  it do
    is_expected.to contain_s3daemon__instance('site').with(
      s3_endpoint_url: "https://s3.#{node_params[:site]}.lsst.org",
      port: 15_557,
      image: 'ghcr.io/lsst-dm/s3daemon:sha-b5e72fa'
    )
  end
end
