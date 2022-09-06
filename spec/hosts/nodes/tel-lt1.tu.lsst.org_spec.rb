# frozen_string_literal: true

require 'spec_helper'

describe 'tel-lt1.tu.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'tel-lt1.tu.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'generic',
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.not_to contain_class('resolv_conf') }
    end # on os
  end # on_supported_os
end # role
