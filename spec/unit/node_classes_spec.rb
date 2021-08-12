# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'node layer' do
  node_files.sort.each do |y|
    context y do
      f = File.join(node_dir, y)
      # #safe_load failed on anchor/aliases
      n = YAML.load_file(f)

      it 'has no classes' do
        expect(n['classes']).to be_nil
      end
    end
  end
end
