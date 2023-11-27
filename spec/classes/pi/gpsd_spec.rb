# frozen_string_literal: true

require 'spec_helper'

describe 'profile::pi::gpsd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'without params' do
        it { is_expected.to compile.with_all_deps }

        include_examples 'gpsd'
        it { is_expected.not_to contain_augeas('gpsd options') }
      end

      context 'without options param' do
        let(:params) { { options: '-n /dev/ttyS0 /dev/pps0' } }

        it { is_expected.to compile.with_all_deps }

        include_examples 'gpsd'
        it do
          is_expected.to contain_augeas('gpsd options').with(
            changes: "set OPTIONS \"\\\"#{params[:options]}\\\"\"",
          )
        end
      end
    end
  end
end
