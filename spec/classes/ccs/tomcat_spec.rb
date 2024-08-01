# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ccs::tomcat' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with args' do
        let(:params) do
          {
            jars: { 'h2-1.4.191.jar': 'https://repo1.maven.org/maven2/com/h2database/h2/1.4.191/h2-1.4.191.jar' },
            rest_url: 'myurl',
            trending_site: 'mysite',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_file('/etc/ccs/tomcat').with_ensure('directory') }

        it { is_expected.to contain_file('/etc/ccs/tomcat/statusPersister.properties').with_mode('0660') }

        it { is_expected.to contain_file('/etc/ccs/tomcat/statusPersister.properties').with_content(sensitive(%r{^hibernate.connection.url=jdbc:mysql://myurl})) }

        it { is_expected.to contain_file('/opt/tomcat/catalina_base/lib/h2-1.4.191.jar').with_mode('0664') }

        it { is_expected.to contain_augeas('context-/opt/tomcat/catalina_base-parameter-org.lsst.ccs.imagenaming.rest.dbURL') }

        it { is_expected.to contain_concat('/opt/tomcat/catalina_base/conf/catalina.properties') }

        it do
          is_expected.to contain_concat__fragment('/opt/tomcat/catalina_base/conf/catalina.properties property org.lsst.ccs.web.trending.default.site').with(
            {
              target: '/opt/tomcat/catalina_base/conf/catalina.properties',
              content: 'org.lsst.ccs.web.trending.default.site=mysite',
            },
          )
        end

        it do
          is_expected.to contain_service('tomcat').with(
            ensure: 'running',
            enable: true,
          )
        end
      end
    end
  end
end
