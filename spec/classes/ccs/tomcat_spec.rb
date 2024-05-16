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

        ## This should contain the line
        ## ^hibernate.connection.url=jdbc:mysql://myurl$
        ## but that is a function of epp().
        it { is_expected.to contain_file('/etc/ccs/tomcat/statusPersister.properties').with_mode('0660') }

        it { is_expected.to contain_file('/opt/tomcat/catalina_base/lib/h2-1.4.191.jar').with_mode('0664') }

        ## This should contain fragment:
        ## org.lsst.ccs.web.trending.default.site=mysite
        it { is_expected.to contain_concat('/opt/tomcat/catalina_base/conf/catalina.properties') }

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