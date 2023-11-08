# frozen_string_literal: true

shared_examples 'node_exporter' do
  it { is_expected.to contain_class('prometheus::node_exporter').with_version('1.6.1') }
end

shared_examples 'no node_exporter' do
  it { is_expected.not_to contain_class('prometheus::node_exporter') }
end
