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

        # as a performance optimization, test with only one site.  If it is
        # important that a role is better tested, it should have its own spec
        # file.
        site = lsst_sites.sample
        describe "#{role}.#{site}.lsst.org", :site do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts
        end # host
      end # on os
    end # on_supported_os
  end # role
end # catchall_roles.each
