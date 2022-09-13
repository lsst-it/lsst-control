# frozen_string_literal: true

require 'spec_helper'

describe 'profile::icinga::master' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:params) do
        {
          api_name: 'foo',
          api_pwd: 'foo',
          api_user: 'foo',
          ca_salt: 'foo',
          ldap_group_base: 'foo',
          ldap_group_filter: 'foo',
          ldap_pwd: 'foo',
          ldap_resource: 'foo',
          ldap_root: 'foo',
          ldap_server: '192.168.1.1',
          ldap_user_filter: 'foo',
          ldap_user: 'foo',
          mysql_director_db: 'bar',
          mysql_director_pwd: 'bar',
          mysql_director_user: 'bar',
          mysql_icingaweb_db: 'baz',
          mysql_icingaweb_pwd: 'baz',
          mysql_icingaweb_user: 'baz',
          mysql_root: 'foo',
        }
      end

      context 'with all required params' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('icinga-php-library') }
        it { is_expected.to contain_package('icinga-php-thirdparty') }

        it do
          is_expected.to contain_class('icingaweb2::module::director').with(
            git_revision: 'v1.9.1',
          )
        end

        it { is_expected.to contain_class('icingaweb2::module::director::service') }

        it do
          is_expected.to contain_class('icingaweb2::module::incubator').with(
            git_revision: 'v0.18.0',
          )
        end

        it do
          is_expected.to contain_icingaweb2__module('pnp').with(
            git_repository: 'https://github.com/Icinga/icingaweb2-module-pnp',
            git_revision: '8f09274',
          )
        end

        it do
          is_expected.to contain_service('rh-php73-php-fpm').with(
            ensure: 'running',
            enable: true,
          )
        end
      end
    end
  end
end
