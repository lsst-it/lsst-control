# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ts::dco' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      include_examples 'dco'
    end
  end
end
