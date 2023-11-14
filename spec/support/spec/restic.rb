# frozen_string_literal: true

shared_examples 'restic common' do
  it do
    is_expected.to contain_class('restic').with(
      bucket: "rubin-bm-backups/#{facts[:fqdn]}",
      enable_backup: true,
      host: 's3.us-east-1.amazonaws.com',
    )
  end
end
