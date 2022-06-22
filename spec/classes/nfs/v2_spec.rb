# frozen_string_literal: true

require 'spec_helper'

describe 'profile::nfs::v2' do
  it 'enables NFS V2' do
    is_expected.to contain_augeas('RPCNFSDARGS="-V 2"').with(
      changes: 'set RPCNFSDARGS \'"-V 2"\'',
    )
  end
end
