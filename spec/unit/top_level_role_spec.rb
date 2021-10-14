# frozen_string_literal: true

require 'spec_helper'

# all hiera role layers
def role_layers
  public_hierarchy.grep(%r{role})
end

# exclude org/lsst/role/
# XXX this will change to role/ when org/nts/ is removed from the tree
def bottom_role_layers
  role_layers.grep_v(%r[org/%{org}/role/%{role}.yaml])
end

def files_in_layer(layer)
  yaml_glob = layer.gsub(%r{%{\w+?}}, '**')
  glob = File.join(control_hieradata_path, yaml_glob)
  Dir[glob]
end

def bottom_role_files
  bottom_role_layers.map { |l| files_in_layer(l) }
                    .flatten
                    .grep_v(%r{nts})
end

hieradata_pathname = Pathname.new(control_hieradata_path)

describe 'hiera' do
  bottom_role_files.sort.each do |y|
    y_relpath = Pathname.new(y).relative_path_from(hieradata_pathname)
    describe y_relpath do
      it 'has a org/lsst/role/ top level role' do
        role_name = y_relpath.basename('.yaml').to_s
        expect(lsst_roles.include?(role_name)).to be true
      end
    end
  end
end
