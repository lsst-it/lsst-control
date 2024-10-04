# frozen_string_literal: true

require 'spec_helper'

def hiera_role_files
  hiera_role_layers.map { |l| hiera_files_in_layer(l) }.flatten
end

hieradata_pathname = Pathname.new(control_hieradata_path)

describe 'hiera' do
  hiera_role_files.sort.each do |f|
    f_relpath = Pathname.new(f).relative_path_from(hieradata_pathname)
    y = YAML.load_file(f, aliases: true)
    next unless y.key?('classes')

    describe f_relpath do
      it 'classes key is sorted' do
        k = y['classes']
        expect(k).to eq k.sort
      end
    end
  end
end
