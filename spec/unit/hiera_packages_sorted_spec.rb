# frozen_string_literal: true

require 'spec_helper'

hieradata_pathname = Pathname.new(control_hieradata_path)

describe 'hiera' do
  hiera_all_files.sort.each do |f|
    f_relpath = Pathname.new(f).relative_path_from(hieradata_pathname)
    y = YAML.load_file(f, aliases: true)
    next unless y.key?('packages')

    describe f_relpath do
      it 'packages key is sorted' do
        k = y['packages']
        expect(k).to eq k.sort
      end
    end
  end
end
