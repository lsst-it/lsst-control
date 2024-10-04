# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

# extract public hiera hierachy
def non_role_layers
  hc = YAML.load_file(control_hiera_config, aliases: true)
  hc['hierarchy'][1]['paths'].grep_v(%r{role})
end

hieradata_pathname = Pathname.new(control_hieradata_path)

describe 'hiera' do
  non_role_layers.each do |layer_conf|
    describe "layer #{layer_conf}" do
      hiera_files_in_layer(layer_conf).sort.each do |y|
        y_relpath = Pathname.new(y).relative_path_from(hieradata_pathname)
        describe y_relpath do
          # #safe_load failed on anchor/aliases
          n = YAML.load_file(y, aliases: true)

          it 'has no classes' do
            expect(n['classes']).to be_nil
          end
        end
      end
    end
  end
end
