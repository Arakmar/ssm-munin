require 'spec_helper'

describe 'munin::master' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      case facts[:osfamily]
      when 'Solaris'
        conf_dir = '/opt/local/etc/munin'
      when 'FreeBSD'
        conf_dir = '/usr/local/etc/munin'
      else
        conf_dir = '/etc/munin'
      end

      it { should compile.with_all_deps }

      it { should contain_package('munin') }

      context 'with default params' do
        it do
          should contain_file("#{conf_dir}/munin.conf")
                  .with_content(/graph_strategy\s+cgi/)
                  .with_content(/html_strategy\s+cgi/)
        end

        it do
          should contain_file("#{conf_dir}/munin-conf.d")
                  .with_ensure('directory')
        end
      end

      context 'with html_strategy => cron' do
        let (:params) { { :html_strategy => 'cron' } }
        it { should compile.with_all_deps }
        it {
          should contain_file("#{conf_dir}/munin.conf")
                  .with_content(/html_strategy\s+cron/)
        }
      end

      context 'with graph_strategy => cron' do
        let (:params) { { :graph_strategy => 'cron' } }
        it { should compile.with_all_deps }
        it {
          should contain_file("#{conf_dir}/munin.conf")
                  .with_content(/graph_strategy\s+cron/)
        }
      end

      context 'with dbdir => /var/lib/munin' do
        let (:params) { { :dbdir => '/var/lib/munin' } }
        it { should compile.with_all_deps }
        it {
          should contain_file("#{conf_dir}/munin.conf")
                  .with_content(/dbdir\s+\/var\/lib\/munin/)
        }
      end

      context 'with htmldir => /var/www/munin' do
        let (:params) { { :htmldir => '/var/www/munin' } }
        it { should compile.with_all_deps }
        it {
          should contain_file("#{conf_dir}/munin.conf")
                  .with_content(/htmldir\s+\/var\/www\/munin/)
        }
      end

      context 'with logdir => /var/log/munin' do
        let (:params) { { :dbdir => '/var/log/munin' } }
        it { should compile.with_all_deps }
        it {
          should contain_file("#{conf_dir}/munin.conf")
                  .with_content(/dbdir\s+\/var\/log\/munin/)
        }
      end

      context 'with rundir => /var/run/munin' do
        let (:params) { { :dbdir => '/var/run/munin' } }
        it { should compile.with_all_deps }
        it {
          should contain_file("#{conf_dir}/munin.conf")
                  .with_content(/dbdir\s+\/var\/run\/munin/)
        }
      end

      context 'with tls => enabled' do
        let(:params) {
          {
            :tls => 'enabled',
            :tls_certificate => '/path/to/certificate.pem',
            :tls_private_key => '/path/to/key.pem',
            :tls_verify_certificate => 'yes',
          }
        }

        it { should compile.with_all_deps }
        it {
          should contain_file("#{conf_dir}/munin.conf")
                  .with_content(/tls = enabled/)
                  .with_content(/tls_certificate = \/path\/to\/certificate\.pem/)
                  .with_content(/tls_private_key = \/path\/to\/key\.pem/)
                  .with_content(/tls_verify_certificate = yes/)
        }
      end


      context 'with extra_config' do
        token = '1b7febce-bb2d-4c18-b889-84c73538a900'
        let(:params) do
          { :extra_config => [ token ] }
        end
        it { should compile.with_all_deps }
        it do
          should contain_file("#{conf_dir}/munin.conf")
                  .with_content(/#{token}/)
        end
      end

      context 'with extra_config set to a string' do
        token = '1b7febce-bb2d-4c18-b889-84c73538a900'
        let(:params) do
          { :extra_config => token }
        end
        it { should raise_error(Puppet::Error, /is not an Array/) }
      end

      ['test.example.com', 'invalid/hostname.example.com'].each do |param|
        context "with host_name => #{param}" do
          let(:params) do
            { :host_name => param }
          end
          if param =~ /invalid/
            it { should raise_error(Puppet::Error, /valid domain name/) }
          else
            it { should compile.with_all_deps }
          end
        end
      end

      %w( enabled disabled mine unclaimed invalid ).each do |param|
        context "with collect_nodes => #{param}" do
          let(:params) do
            { :collect_nodes => param }
          end
          if param == 'invalid'
            it { should raise_error(Puppet::Error, /validate_re/) }
          else
            it { should compile.with_all_deps }
          end
        end
      end

    end # on os
  end

end
