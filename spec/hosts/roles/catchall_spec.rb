# frozen_string_literal: true

require 'spec_helper'

def spec_roles
  spec_dir = File.join(spec_path, 'hosts/roles')
  role_names = Dir.entries(spec_dir).grep_v(%r{^\.}).map { |x| x.sub('_spec.rb', '') }
  role_names.map { |x| x.gsub('_', '-') }
end

def roles_without_spec
  hiera_roles - spec_roles
end

roles_without_spec.each do |role|
  describe "#{role} role" do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge(
            fqdn: self.class.description,
          )
        end

        let(:node_params) do
          {
            role: role,
            site: site,
          }
        end

        lsst_sites.each do |site|
          describe "#{role}.#{site}.lsst.org", :site, :common do
            let(:site) { site }

            it { is_expected.to compile.with_all_deps }
          end # host
        end # lsst_sites
      end # on os
    end # on_supported_os
  end # role
end # catchall_roles.each
