require "spec_helper"
require "serverspec"
require "json"

# rubocop:disable Style/GlobalVars
$BACKEND_DATABASE ||= "postgresql"
# rubocop:enable Style/GlobalVars

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
api_url = "http://127.0.0.1/api_jsonrpc.php"

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
ca_pub = "#{conf_dir}/cert/ca.pub"
server_pub = "#{conf_dir}/cert/server.pub"
server_key = "#{conf_dir}/cert/server.key"
agent_pub = "#{conf_dir}/cert/agent.pub"
agent_key = "#{conf_dir}/cert/agent.key"

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
  its(:content) { should match(/TLS support:\s+YES/) }

  # test if the server process successfuly connected to the agent
  its(:content) do
    pending "zabbix server version on OpenBSD does not log any successful connection to the agent" if os[:family] == "openbsd"
    should match(/enabling Zabbix agent checks on host "Zabbix server": interface became available/)
  end
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

  describe command "pkg info #{package}" do
    its(:stderr) { should eq "" }
    case $BACKEND_DATABASE
    when "mysql"
      its(:stdout) { should match(/MYSQL\s+:\s+on/) }
    when "postgresql"
      its(:stdout) { should match(/PGSQL\s+:\s+on/) }
    else
      raise "Unknown $BACKEND_DATABASE `#{$BACKEND_DATABASE}`"
    end
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

describe file ca_pub do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/BEGIN CERTIFICATE/) }
end

describe file agent_pub do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/BEGIN CERTIFICATE/) }
end

describe file agent_key do
  it { should exist }
  it { should be_file }
  it { should be_mode 600 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/BEGIN RSA PRIVATE KEY/) }
end

describe file server_pub do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/BEGIN CERTIFICATE/) }
end

describe file server_key do
  it { should exist }
  it { should be_file }
  it { should be_mode 600 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/BEGIN RSA PRIVATE KEY/) }
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

# until zabbixapi gem supports 5.4, workaround by hand-crafted curl version of
# tests.
describe "API" do
  let(:header) { "Content-Type: application/json-rpc" }
  let(:url) { api_url }
  let(:response) do
    r = Specinfra.backend.run_command("curl -s -X POST -H #{header.shellescape} -d #{body.to_json.shellescape} #{url.shellescape}").stdout
    JSON.parse(r)
  end
  let(:result) { response["result"] }
  let(:auth) do
    b = {
      "jsonrpc" => "2.0",
      "method" => "user.login",
      "params" => {
        "user" => "Admin",
        "password" => "api_password"
      },
      "id" => 1,
      "auth" => nil
    }
    r = Specinfra.backend.run_command("curl -s -X POST -H #{header.shellescape} -d #{b.to_json.shellescape} #{url.shellescape}").stdout
    JSON.parse(r)["result"]
  end

  describe "host.get" do
    let(:body) do
      {
        "jsonrpc" => "2.0",
        "method" => "host.get",
        "params" => {
          "filter" => {
            "host" => [
              "Zabbix server"
            ]
          }
        },
        "id" => 1,
        "auth" => auth
      }
    end

    it "returns Zabbix server" do
      expect(response).not_to include("error")
      expect(result.first["host"]).to eq "Zabbix server"
    end
  end

  describe "drule.get" do
    let(:body) do
      {
        "jsonrpc" => "2.0",
        "method" => "drule.get",
        "params" => {
          "output" => "extend",
          "selectDChecks" => "extend"
        },
        "id" => 1,
        "auth" => auth
      }
    end

    it "includes `LAN` discovery rule" do
      expect(response).not_to include("error")

      # XXX expect two discovery rules. one default rule and, another we
      # created in the test
      expect(result.length).to eq 2
      expect(result[1]["name"]).to eq "LAN"
    end
  end
end
