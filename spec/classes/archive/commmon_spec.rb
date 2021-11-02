# frozen_string_literal: true

require 'spec_helper'

describe 'profile::archive::common', :archiver do
  let(:node_params) do
    {
      org: 'lsst',
      site: 'dev',
      ipa_force_join: false,  # XXX fix easy_ipa mod
    }
  end

  it { is_expected.to compile.with_all_deps }
end
