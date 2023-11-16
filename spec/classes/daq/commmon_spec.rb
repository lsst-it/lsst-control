# frozen_string_literal: true

require 'spec_helper'

describe 'profile::daq::common' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      include_examples 'daq common'
    end
  end
end
