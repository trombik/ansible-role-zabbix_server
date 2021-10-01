require "spec_helper"
require "serverspec"

package = "zabbix_server"
service = "zabbix_server"
user    = "zabbix"
group   = "zabbix"
ports   = [10051]
conf_dir = "/etc/zabbix"
default_user = "root"
default_group = "root"

case os[:family]
when "freebsd"
  package = "zabbix54-server"
  conf_dir = "/usr/local/etc/zabbix54"
  default_group = "wheel"
end
config  = "#{conf_dir}/zabbix_server.conf"

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 640 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match Regexp.escape("Managed by ansible") }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/zabbix_server") do
    it { should be_file }
    it { should exist }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match Regexp.escape("Managed by ansible") }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
