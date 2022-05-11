# frozen_string_literal: true

require 'spec_helper'

def bottom_role_layers
  # remove lowest priority layer
  hiera_role_layers[0...-1]
end

def bottom_role_files
  bottom_role_layers.map { |l| hiera_files_in_layer(l) }.flatten
end

hieradata_pathname = Pathname.new(control_hieradata_path)

describe 'hiera' do
  bottom_role_files.sort.each do |y|
    y_relpath = Pathname.new(y).relative_path_from(hieradata_pathname)
    describe y_relpath do
      it 'has a top level role' do
        role_name = y_relpath.basename('.yaml').to_s
        expect(hiera_roles.include?(role_name)).to be true
      end
    end
  end
end
