# frozen_string_literal: true

shared_examples 's3nd' do
  it { is_expected.to contain_class('s3nd') }
end
