# frozen_string_literal: true

require 'spec_helper'

describe 'profile::nfs::v2' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      include_examples 'nfsv2 enabled', os_facts: os_facts
    end
  end
end
