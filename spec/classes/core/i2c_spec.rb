# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::i2c' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      os_facts = override_facts(os_facts, cpuinfo: {
                                  'processor' => {
                                    'Model' => 'Raspberry Pi 4 Model B Rev 1.2',
                                  },
                                })
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      include_examples 'i2c', os_facts: os_facts
    end
  end
end
