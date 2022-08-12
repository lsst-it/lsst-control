# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::bash_completion' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      if facts[:os]['family'] == 'RedHat'
        it { is_expected.to contain_package('bash-completion') }

        if facts[:os]['release']['major'] == '7'
          it { is_expected.to contain_package('bash-completion-extras') }
        else
          it { is_expected.not_to contain_package('bash-completion-extras') }
        end
      end
    end
  end
end
