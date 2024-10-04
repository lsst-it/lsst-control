# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::krb5' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with no params' do
        it { is_expected.to compile.with_all_deps }

        include_examples 'krb5.conf.d files', os_facts:
      end
    end
  end
end
