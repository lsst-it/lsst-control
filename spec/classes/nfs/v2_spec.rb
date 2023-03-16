# frozen_string_literal: true

require 'spec_helper'

describe 'profile::nfs::v2' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      include_examples 'nfsv2 enabled', facts: facts
    end
  end
end
