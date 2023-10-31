# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::krb5' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with no params' do
        it { is_expected.to compile.with_all_deps }

        include_examples 'krb5.conf.d files', facts: facts
      end
    end
  end
end
