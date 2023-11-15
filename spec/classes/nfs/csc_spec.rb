# frozen_string_literal: true

require 'spec_helper'

describe 'profile::nfs::client::csc' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default module data' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('nfs::client') }
        it { is_expected.to have_nfs__client__mount_resource_count(6) }
      end
    end
  end
end
