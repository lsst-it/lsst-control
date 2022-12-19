# frozen_string_literal: true

require 'spec_helper'

describe "manke cluster" do
  let(:node_params) do
    {
       role: 'rke',
       site: 'ls',
       cluster: 'manke',
    }
  end

  %w[
    enp129s0f0
    enp129s0f1
  ].each do |int|
    it do
      is_expected.to contain_network__interface(int)
        .with_ensure('present')
    end
  end
end
