require "spec_helper"
require "serverspec"

package = "zabbix-server-pgsql"
service = "zabbix-server"
log_dir = "/var/log/zabbix"
pid_dir = "/run/zabbix"
socket_dir = "/run/zabbix"
externalscripts_dir = "/usr/lib/zabbix/externalscripts"
user    = "zabbix"
group   = "zabbix"
ports   = [
  80,
  9000,
  10_050,
  10_051
]
conf_dir = "/etc/zabbix"
default_user = "root"
default_group = "root"

case os[:family]
when "freebsd"
  package = "zabbix54-server"
  conf_dir = "/usr/local/etc/zabbix54"
  default_group = "wheel"
  service = "zabbix_server"
  pid_dir = "/var/run/zabbix"
  socket_dir = "/var/run/zabbix"
  externalscripts_dir = "#{conf_dir}/externalscripts"
when "openbsd"
  user = "_zabbix"
  group = "_zabbix"
  package = "zabbix-server-5.0.10-pgsql"
  conf_dir = "/etc/zabbix"
  default_group = "wheel"
  service = "zabbix_server"
  pid_dir = "/var/run/zabbix"
  socket_dir = "/var/run/zabbix"
  externalscripts_dir = "#{conf_dir}/externalscripts"
end

config = "#{conf_dir}/zabbix_server.conf"

describe package(package) do
  it { should be_installed }
end

describe file(log_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  it { should be_mode 755 }
end

describe file("#{log_dir}/zabbix_server.log") do
  it { should exist }
  it { should be_file }
  it { should be_mode 664 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(pid_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  it { should be_mode 755 }
end

describe file(socket_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  it { should be_mode 755 }
end

describe file(log_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  it { should be_mode 755 }
end

describe file(externalscripts_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  it { should be_mode 755 }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 600 }
  it { should be_owned_by default_user }
  case os[:family]
  when "openbsd"
    it { should be_grouped_into group }
  else
    it { should be_grouped_into default_group }
  end
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

describe file "#{externalscripts_dir}/test.sh" do
  it { should exist }
  it { should be_file }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/# Test external script/) }
end

describe file "#{externalscripts_dir}/remove_me.sh" do
  it { should_not exist }
end

# zabbixapi gem does not support 5.4. as a result, cannot test tasks in the
# role. see:
# https://github.com/express42/zabbixapi/issues/110
# require "zabbixapi"
#
# zbx =  ZabbixApi.connect(
#   :url => api_url,
#   :user => api_user,
#   :password => api_password,
#   :ignore_version => true,
# )
#
# users = zbx.users.get_id(alias: "Admin")
