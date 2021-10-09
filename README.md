# `trombik.zabbix_server`

Manage `zabbix` server. The role manages users, user groups, and discovery
rules. Other `zabbix` resources should be managed by your own roles.

`zabbix` resources are managed by `zabbix` user `Admin`. If this is a concern,
create an API user, and use that user in your role. The role has all access,
including access to the database.

The role supports FreeBSD, OpenBSD, and Debian variants.

The role support `PostgreSQL`, `MySQL` and `MariaDB`.

The role is still in beta.

## Notes for all users

The role overrides the default login password of `Admin`, which can be
controlled by `zabbix_server_api_login_password`.

The example uses many my `ansible` roles (see [`requirements.yml`](requirements.yml`)),
but they are all optional. You may use any other roles.

## Notes for FreeBSD users

[`net-mgmt/zabbix54-server`](https://www.freshports.org/net-mgmt/zabbix54-server/)
in the official FreeBSD package tree is built with `MySQL`. You need to build
your own with `PostgreSQL` option enabled.

The role does not work out of box because `zabbix-api` port is not in the
official FreeBSD ports tree. My `py-zabbix-api` is available at
[`trombik/freebsd-ports-py-zabbix-api`](https://github.com/trombik/freebsd-ports-py-zabbix-api).

## Notes for Debian users

The role installs `py-zabbix-api` with `pip` as root.

## Notes for OpenBSD users

The role installs `py-zabbix-api` with `pip` as root.

## TLS

See [Encryption](https://www.zabbix.com/documentation/current/manual/encryption)
in the official documentation for details.

Supported TLS encryption includes:

* TLS between `zabbix` agent and `zabbix` server with certificates

The role manages encryption setting of `zabbix` agent on the `zabbix` server.
See `zabbix_server_agent_tls_accept` and `zabbix_server_agent_tls_connect`.
The default is `No encryption`.

### TLS between `zabbix` agent and `zabbix` server with certificates

To enable TLS, you need:

* Two public keys (root CA and host's public key signed by the CA)
* A private key of the host

The public and private keys in the example were created by the following
commands.

```console
openssl genrsa -aes256 -out ca.key 4096
openssl req -x509 -new -key ca.key -sha256 -days 3560 -out ca.pub
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr
openssl x509 -req -in server.csr -CA ca.pub -CAkey ca.key -CAcreateserial -out server.pub -days 3650 -sha256
```

`ca.pub` is the public key of the CA. Both the agent and the server needs it.

`server.pub` is the public key of the server. `server.key` is the private key
of the server.

`ca.key` is the private key of the CA. You need this to sign other signing
request. The role does not use it.

`server.csr` is a signing request. The role does not use it.

To distribute keys, the example uses [`trombik.x509_certificate`](https://github.com/trombik/ansible-role-x509_certificate) by including it.
However, you may use other means. If you do not use
[`trombik.x509_certificate`], set `zabbix_server_x509_certificates` to empty
list (the default).

# Requirements

The roles requires `ansible` collections. See [`requirements.yml`](requirements.yml).

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `zabbix_server_user` | user name of `zabbix` server | `{{ __zabbix_server_user }}` |
| `zabbix_server_group` | group name of `zabbix` server | `{{ __zabbix_server_group }}` |
| `zabbix_server_db_dir` | | `{{ __zabbix_server_db_dir }}` |
| `zabbix_server_service` | service name of `zabbix` server | `{{ __zabbix_server_service }}` |
| `zabbix_server_package` | package name of `zabbix` server | `{{ __zabbix_server_package }}` |
| `zabbix_server_extra_packages` | a list of extra packages to install | `{{ __zabbix_server_extra_packages }}` |
| `zabbix_server_conf_dir` | path to configuration directory | `{{ __zabbix_server_conf_dir }}` |
| `zabbix_server_conf_file` | path to `zabbix_server.conf` | `{{ zabbix_server_conf_dir }}/zabbix_server.conf` |
| `zabbix_server_flags` | TBW | `""` |
| `zabbix_server_backend_database` | name of back-end database package (only `postgresql` is supported) | `postgresql` |
| `zabbix_server_backend_database_sql_base_dir` | path to directory where SQL files for databases are kept | `{{ __zabbix_server_backend_database_sql_base_dir }}` |
| `zabbix_server_backend_database_sql_dir` | path to directory where SQL files for `zabbix_server_backend_database` is kept | `{{ zabbix_server_backend_database_sql_base_dir }}/{{ zabbix_server_backend_database }}` |
| `zabbix_server_backend_database_name` | database name | `zabbix` |
| `zabbix_server_backend_database_user` | database user name | `zabbix` |
| `zabbix_server_backend_database_host` | host name or IP address of database | `localhost` |
| `zabbix_server_backend_database_password` | password of `zabbix_server_backend_database_user` | `""` |
| `zabbix_server_listen_port` | port for `zabbix` server to listen on | `10051` |
| `zabbix_server_api_login_password` | login password for API access | `""` |
| `zabbix_server_api_login_user` | login user name for API access | `Admin` |
| `zabbix_server_api_server_url` | URL of API endpoint | `http://localhost/zabbix` |
| `zabbix_server_users` | a list of `zabbix` users to manage | `[]` |
| `zabbix_server_usergroups` | a list of `zabbix` user groups to manage | `[]` |
| `zabbix_server_discovery_rules` | a list of discovery rules to manage | `[]` |
| `zabbix_server_backend_database_sql_files` | a list of file name without directory, i.e. `basename`, to initialize database | `{{ __zabbix_server_backend_database_sql_files }}` |
| `zabbix_server_python_api_package` | name of python package to access API | `{{ __zabbix_server_python_api_package }}` |
| `zabbix_server_log_dir` | path to log directory | `{{ __zabbix_server_log_dir }}` |
| `zabbix_server_log_file` | path to log file | `{{ zabbix_server_log_dir }}/zabbix_server.log` |
| `zabbix_server_pid_dir` | path to PID directory | `{{ __zabbix_server_pid_dir }}` |
| `zabbix_server_pid_file` | path to PID file | `{{ zabbix_server_pid_dir }}/zabbix_server.pid` |
| `zabbix_server_socket_dir` | path to socket directory | `{{ __zabbix_server_socket_dir }}` |
| `zabbix_server_externalscripts_dir` | path to `externalscripts` directory | `{{ __zabbix_server_externalscripts_dir }}` |
| `zabbix_server_externalscripts_files` | a list of `externalscripts` to manage | `[]` |
| `zabbix_server_agent_host_name` | name of the `zabbix` agent on `zabbix` server | `Zabbix server` |
| `zabbix_server_agent_tls_accept` | the value of `TLSAccept` for `zabbix` agent on `zabbix` server | `1` |
| `zabbix_server_agent_tls_connect` | the value of `TLSConnect` for `zabbix` agent on `zabbix` server | `1` |
| `zabbix_server_x509_cert_dir` | path to directory where certificates are kept. the role creates the directory | `"{{ zabbix_server_conf_dir }}/cert` |
| `zabbix_server_x509_certificates` | list of certificates to manage. when the length is more then zero, the role include `trombik.x509_certificate` and pass the list to `trombik.x509_certificate` | `[]` |
| `zabbix_server_debug` | if `no`, set `no_log: yes` on some tasks where sensitive information, such as password, is used in loop to prevent leak. do not set to `yes` on production | `no` |

## Debian

| Variable | Default |
|----------|---------|
| `__zabbix_server_user` | `zabbix` |
| `__zabbix_server_group` | `zabbix` |
| `__zabbix_server_service` | `zabbix-server` |
| `__zabbix_server_package` | `zabbix-server-pgsql` |
| `__zabbix_server_extra_packages` | `["zabbix-sql-scripts"]` |
| `__zabbix_server_conf_dir` | `/etc/zabbix` |
| `__zabbix_server_backend_database_sql_base_dir` | `/usr/share/doc/zabbix-sql-scripts` |
| `__zabbix_server_backend_database_sql_files` | `["create.sql.gz"]` |
| `__zabbix_server_python_api_package` | `zabbix-api` |
| `__zabbix_server_log_dir` | `/var/log/zabbix` |
| `__zabbix_server_pid_dir` | `/run/zabbix` |
| `__zabbix_server_socket_dir` | `/run/zabbix` |
| `__zabbix_server_externalscripts_dir` | `/usr/lib/zabbix/externalscripts` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__zabbix_server_user` | `zabbix` |
| `__zabbix_server_group` | `zabbix` |
| `__zabbix_server_service` | `zabbix_server` |
| `__zabbix_server_package` | `net-mgmt/zabbix54-server` |
| `__zabbix_server_extra_packages` | `[]` |
| `__zabbix_server_conf_dir` | `/usr/local/etc/zabbix54` |
| `__zabbix_server_backend_database_sql_base_dir` | `/usr/local/share/zabbix54/server/database` |
| `__zabbix_server_backend_database_sql_files` | `["schema.sql", "images.sql", "data.sql"]` |
| `__zabbix_server_python_api_package` | `py38-zabbix-api` |
| `__zabbix_server_log_dir` | `/var/log/zabbix` |
| `__zabbix_server_pid_dir` | `/var/run/zabbix` |
| `__zabbix_server_socket_dir` | `/var/run/zabbix` |
| `__zabbix_server_externalscripts_dir` | `/usr/local/etc/zabbix54/externalscripts` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__zabbix_server_user` | `_zabbix` |
| `__zabbix_server_group` | `_zabbix` |
| `__zabbix_server_service` | `zabbix_server` |
| `__zabbix_server_package` | `zabbix-server--pgsql` |
| `__zabbix_server_extra_packages` | `[]` |
| `__zabbix_server_conf_dir` | `/etc/zabbix` |
| `__zabbix_server_backend_database_sql_base_dir` | `/usr/local/share/zabbix-server/schema` |
| `__zabbix_server_backend_database_sql_files` | `["schema.sql", "images.sql", "data.sql"]` |
| `__zabbix_server_python_api_package` | `zabbix-api` |
| `__zabbix_server_log_dir` | `/var/log/zabbix` |
| `__zabbix_server_pid_dir` | `/var/run/zabbix` |
| `__zabbix_server_socket_dir` | `/var/run/zabbix` |
| `__zabbix_server_externalscripts_dir` | `/etc/zabbix/externalscripts` |

# Dependencies

None

# Example Playbook

The example creates `zabbix` server with `zabbix` agent, including web UI and
the database.

```yaml
---
- hosts: localhost
  roles:
    - role: trombik.sysctl
    - role: trombik.freebsd_pkg_repo
      when: ansible_os_family == 'FreeBSD'
    - role: trombik.apt_repo
      when: ansible_os_family == 'Debian'
    - role: trombik.pip
      when: ansible_os_family == 'Debian' or ansible_os_family == 'OpenBSD'
    - role: trombik.postgresql
    - role: trombik.zabbix_agent
    - role: trombik.zabbix_frontend
    - role: trombik.nginx
    # XXX zabbix_server uses APIs. the frontend must be configured
    # before server
    - role: trombik.php_fpm
    - ansible-role-zabbix_server
  vars:
    # XXX use my own package repository as the package in the official package
    # tree does not include postgresql support.
    # also, py38-zabbix-api is not in the tree.
    freebsd_pkg_repo:
      local:
        enabled: "true"
        state: present
        url: "http://pkg.i.trombik.org/{{ ansible_distribution_version | regex_replace('\\.') }}{{ ansible_architecture }}-default-default"
        priority: 99

    apt_repo_enable_apt_transport_https: yes
    # https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb
    apt_repo_keys_to_add:
      - https://repo.zabbix.com/zabbix-official-repo.key
    apt_repo_to_add:
      - "deb https://repo.zabbix.com/zabbix/5.4/{% if ansible_distribution == 'Devuan' %}debian {{ apt_repo_codename_devuan_to_debian[ansible_distribution_release] }} main{% else %}{{ ansible_distribution | lower }} {{ ansible_distribution_release }} main {% endif %}"
      - "deb-src https://repo.zabbix.com/zabbix/5.4/{% if ansible_distribution == 'Devuan' %}debian {{ apt_repo_codename_devuan_to_debian[ansible_distribution_release] }} main{% else %}{{ ansible_distribution | lower }} {{ ansible_distribution_release }} main {% endif %}"
    zabbix_server_debug: yes
    zabbix_server_backend_database_password: password

    # XXX no trailing `/`
    zabbix_server_api_server_url: http://localhost

    # password hash can be created by:
    # <?php
    # $p = password_hash("api_password", PASSWORD_BCRYPT);
    # echo "$p\n"
    # ?>
    #
    # this is the password of `Admin` user.
    zabbix_server_api_login_password: api_password
    zabbix_server_usergroups:
      - name: Developers
        debug_mode: enabled
        rights:
          - host_group: Linux servers
            permission: read-write
        state: present
    zabbix_server_users:
      - alias: trombik
        name: Me
        surname: Surname
        passwd: password
        type: Zabbix admin
        usrgrps:
          - Guests
          - Developers
      - alias: root
        name: Root
        surname: Surname
        passwd: password
        type: Zabbix super admin
        usrgrps:
          - Zabbix administrators
    zabbix_server_discovery_rules:
      - name: LAN
        iprange: 192.168.1.1-255
        dchecks:
          - type: ICMP
          - type: Zabbix
            key: "system.hostname"
            ports: 10050
            uniq: yes
            host_source: "discovery"
        status: enabled

    project_server_ca_pub_file: "{{ zabbix_server_x509_cert_dir }}/ca.pub"
    project_server_pub_file: "{{ zabbix_server_x509_cert_dir }}/server.pub"
    project_server_key_file: "{{ zabbix_server_x509_cert_dir }}/server.key"
    zabbix_server_agent_tls_accept: 4
    zabbix_server_agent_tls_connect: 4
    zabbix_server_config: |
      ListenPort={{ zabbix_server_listen_port }}
      DBHost={{ zabbix_server_backend_database_host }}
      DBName={{ zabbix_server_backend_database_name }}
      DBUser={{ zabbix_server_backend_database_user }}
      DBPassword={{ zabbix_server_backend_database_password }}
      LogSlowQueries=3000
      StatsAllowedIP=127.0.0.1
      SocketDir={{ zabbix_server_socket_dir }}
      Timeout=4
      LogFile={{ zabbix_server_log_file }}
      LogFileSize=0

      {% if ansible_os_family == 'FreeBSD' or ansible_os_family == 'OpenBSD' %}
      FpingLocation=/usr/local/sbin/fping
      Fping6Location=/usr/local/sbin/fping6
      {% else %}
      # Ubuntu's default
      PidFile={{ zabbix_server_pid_file }}
      SNMPTrapperFile=/var/log/snmptrap/snmptrap.log
      FpingLocation=/usr/bin/fping
      Fping6Location=/usr/bin/fping6
      {% endif %}

      TLSCAFile={{ project_server_ca_pub_file }}
      TLSCertFile={{ project_server_pub_file }}
      TLSKeyFile={{ project_server_key_file }}

    zabbix_server_externalscripts_files:
      - name: test.sh
        content: |
          #!/bin/sh
          # Test external script
          echo 1
          exit 0
        validate: sh -n %s
        state: present
      - name: remove_me.sh
        state: absent

    # _______________________________________________zabbix_agent
    zabbix_agent_debug: yes
    project_agent_ca_pub_file: "{{ zabbix_agent_x509_cert_dir }}/ca.pub"
    project_agent_pub_file: "{{ zabbix_agent_x509_cert_dir }}/agent.pub"
    project_agent_key_file: "{{ zabbix_agent_x509_cert_dir }}/agent.key"
    zabbix_agent_config: |
      Server={{ zabbix_agent_server }}
      ListenPort={{ zabbix_agent_listen_port }}
      ListenIP={{ zabbix_agent_listen_ip }}
      ServerActive={{ zabbix_agent_server }}
      Hostname=Zabbix server
      LogFileSize=0
      LogFile={{ zabbix_agent_log_file }}

      {% if ansible_os_family == 'Debian' %}
      PidFile={{ zabbix_agent_pid_file }}
      {% endif %}

      TLSAccept=cert
      TLSConnect=cert
      TLSCAFile={{ project_agent_ca_pub_file }}
      TLSCertFile={{ project_agent_pub_file }}
      TLSKeyFile={{ project_agent_key_file }}

      Include={{ zabbix_agent_conf_d_dir }}/*.conf
    # _______________________________________________x509
    zabbix_server_x509_certificates:
      - name: ca
        state: present
        public:
          owner: "{{ zabbix_server_user }}"
          group: "{{ zabbix_server_group }}"
          mode: "0644"
          path: "{{ project_server_ca_pub_file }}"
          key: |
            -----BEGIN CERTIFICATE-----
            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
            RLpsEv+JMnbyge94Vh/kGG5PC9LxqTW4Jw==
            -----END CERTIFICATE-----
      - name: server
        state: present
        public:
          path: "{{ project_server_pub_file }}"
          owner: "{{ zabbix_server_user }}"
          group: "{{ zabbix_server_group }}"
          mode: "0644"
          key: |
            -----BEGIN CERTIFICATE-----
            MIIEMjCCAhoCFGwjnXE47m8CJnOmQs8O+jGms4tvMA0GCSqGSIb3DQEBCwUAMFIx
            CzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRl
            cm5ldCBXaWRnaXRzIFB0eSBMdGQxCzAJBgNVBAMMAmNhMB4XDTIxMTAwNTEzMjEx
            NloXDTMxMTAwMzEzMjExNlowWTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUt
            U3RhdGUxITAfBgNVBAoMGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDESMBAGA1UE
            AwwJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvI0P
            DY+/LTUuNmpGjtuReEWtuCLIpTifrmWZhy8WBfrVLpdvvQAvVT0X4qeZACH78yDL
            UwWpA0M1eEYz2TLJP4fh/M6VFE6V0rJo+aCMfosGWUMroe00Y6UvhyTQmgkzh18d
            VulIy3S5fuXzLrzdpAmka9FJu0eDXcEzMqYuO4caLagjPTVzQIRUHFccWPduuaFU
            RPqQWtUDIspYLbCYlcdowXauNVSQfDpYcydHCQdpF0fUokJy8eldnhYMqzq3x7Xc
            Dx4nvwvLkSFbdcLB/TZw5TJkSFwPE3728MCHbOQh+2uxVwOsvT/yVfJm6arSbP/g
            YHXFDWuAORacYqCIbwIDAQABMA0GCSqGSIb3DQEBCwUAA4ICAQAjiLO5H+pcxXdp
            UXDCZViJTPH2kappLplsZruoYdsLkxjRQuS9SvBZc/KbZ9SOFR0WJ/Tz1QgpacPo
            tAoO0VONDx4zZE1sEwgQ217xUMzbXiZz3qd2u24/JMzvwNuKTmqRYFlEK1HKulCg
            DsjoQRc4IBVL3HNrjabyVcoSlec+E5uTnDMSBmd9nOBI7AyBwFcKgLyqtWLtgol/
            ujSVz/76b7UhJoq2Rf7l9tPv8C3ZVLjaq9xN2sKnsfnlLe0qaDtWVG8pm21D+cPl
            YBvCFj27LPBJLmHnU3oe48wLMX6BCImwHciG0hLCJKJ049VjSpJPk5z8S+OQKPGy
            jFDguO/4dAH8WfnC9RNbewF37MkbGGFZT8SlXnFQ+1pKc+AWZbu6LyX3qlVEQjqp
            HwuifXrJd5w0EcCK54J2mKfexM8dKLsQM9EcSNBsYRNUAOtcpNN3tuCjCYNUoqlK
            AjhPMS6EzGM+R55yVSjc4KoJgCoTCRfRs+o4YoE6xB1FlW5XdD1AJAHELTmAip+g
            HII1nNzBidzGd/kCw5+zIUWTV1F8uF3vyeWR+G6YzDnP+b5ojK4VsXs+L+0P8WWw
            SKvIeq9zqIDgseMsGuHEB5pu5rDSTmNVkvJLBb8yjwA47vwRb2c/omRdi9LTO6hn
            ySyPIxx7CcIaBN3MhqC4ckh1E0KftQ==
            -----END CERTIFICATE-----
        secret:
          path: "{{ project_server_key_file }}"
          owner: "{{ zabbix_server_user }}"
          group: "{{ zabbix_server_group }}"
          mode: "0600"
          key: |
            -----BEGIN RSA PRIVATE KEY-----
            MIIEpQIBAAKCAQEAvI0PDY+/LTUuNmpGjtuReEWtuCLIpTifrmWZhy8WBfrVLpdv
            vQAvVT0X4qeZACH78yDLUwWpA0M1eEYz2TLJP4fh/M6VFE6V0rJo+aCMfosGWUMr
            oe00Y6UvhyTQmgkzh18dVulIy3S5fuXzLrzdpAmka9FJu0eDXcEzMqYuO4caLagj
            PTVzQIRUHFccWPduuaFURPqQWtUDIspYLbCYlcdowXauNVSQfDpYcydHCQdpF0fU
            okJy8eldnhYMqzq3x7XcDx4nvwvLkSFbdcLB/TZw5TJkSFwPE3728MCHbOQh+2ux
            VwOsvT/yVfJm6arSbP/gYHXFDWuAORacYqCIbwIDAQABAoIBAQCe8BkcSWvR495M
            qFFJ4vRA+htx+IBCJfUUwTglqB9ccxB48daS7zD3HUShHr3uSrdjPuWl2kOaKHFO
            LX9PO2xBTX3F6S3prETHEvVCV3+WvAJiBCknmhhrVrc1qGbfMZpqJldJB+UA/CfR
            PG09nJ8Iw8gByq3oXGP0CAPsUgDu04JsLBOJpScer1j+GtwF+1KeYM5lcSfgTYK6
            sf9pjCA24XWT9vdt76ayoaJnzDQ77JAS0mE/E5wBeJKXFFac246PZuJiRMlmh/uv
            CGIq37CvV/WHVhfWkBmOTFDMGLFiBxhOAFJKrcrfJNqz359R2a6hNa0BJESu6ORq
            cA4/j9IBAoGBAPl9Ir698rQzMD1ea8eLhSoJmh217Zd3oepQO/uJuf6J6AJrPnhi
            fb/isvIierUNsohFj8aW+fjlSmvy5Q5GKgTOM3IOAUpXvJWXvC+6uf4cngqw2rh4
            fxska8nFGrpAURpxjj40Lbnj7Qnt7pKMrBIu2C2eaMno34gsdHdN8cFBAoGBAMF4
            ylj/MVGnVQ3f/TCnTWqC+E5/L5wbulI6NKzY/yz8RrLPPP7OAWhTDb5RMxXiC3nR
            WvxMZVwqEmK4mQv1IpbJSm1fXzTgu2UY3nIrr+flq9IkfvifNN5KlAYmgZzIXeUE
            /xdVB9vXanodMW6FGi6S6yZMTfDqK3STs+FtJS2vAoGBAPj0stgtiWPh9JA4iUp8
            4evZ2w0svqK3wT2kxMYzYAMsr/TB+Xt9pMf2uuQ+Hb5PpcivyVG81EJW45WmsoU0
            5LcY4GM+sHDz7f5EhIgIR5LYEajPY+JSc1utU1XrNsmGZqgBipRt0vc9Bwsyfy+D
            6izWy+dxvFVG6M/ktG9cuxJBAoGAJ9v45Ej/IjF1RnyFL0boni8JdTKi3migBFzV
            iV7Tg7Md5azohh5vD808oZ8dBT8i2iAVvLEImOpaC1i4v0vrqmEiIlJpzP0X3oY3
            HhJ+FSquMYcvWY2DWODIilPYlDJ7lblnzKjKC7LfzvTAwGJPuJSwOZ2y2RWFimj7
            wE+6PyUCgYEAmxYRvzpChBqSOdfX/IAMTJHYJ0D8QaM0OHykwLpflQL+HwaAEUPJ
            Z35sqvkl1hN0L/RABA2vbYRKpDhqJpIiM2Ff0RN2s4mO/eFShfwOrWo4KObTFUzV
            eQlLeaYnzV5csXaKTi+XBXU+VqrZBvpY27APRmb7JJWl3mgnwSnPjyg=
            -----END RSA PRIVATE KEY-----
    zabbix_agent_x509_certificates:
      - name: ca
        state: present
        public:
          owner: "{{ zabbix_agent_user }}"
          group: "{{ zabbix_agent_group }}"
          mode: "0644"
          path: "{{ project_agent_ca_pub_file }}"
          key: |
            -----BEGIN CERTIFICATE-----
            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
            RLpsEv+JMnbyge94Vh/kGG5PC9LxqTW4Jw==
            -----END CERTIFICATE-----
      - name: agent
        state: present
        public:
          path: "{{ project_agent_pub_file }}"
          owner: "{{ zabbix_agent_user }}"
          group: "{{ zabbix_agent_group }}"
          mode: "0644"
          key: |
            -----BEGIN CERTIFICATE-----
            MIIEMjCCAhoCFGwjnXE47m8CJnOmQs8O+jGms4tvMA0GCSqGSIb3DQEBCwUAMFIx
            CzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRl
            cm5ldCBXaWRnaXRzIFB0eSBMdGQxCzAJBgNVBAMMAmNhMB4XDTIxMTAwNTEzMjEx
            NloXDTMxMTAwMzEzMjExNlowWTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUt
            U3RhdGUxITAfBgNVBAoMGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDESMBAGA1UE
            AwwJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvI0P
            DY+/LTUuNmpGjtuReEWtuCLIpTifrmWZhy8WBfrVLpdvvQAvVT0X4qeZACH78yDL
            UwWpA0M1eEYz2TLJP4fh/M6VFE6V0rJo+aCMfosGWUMroe00Y6UvhyTQmgkzh18d
            VulIy3S5fuXzLrzdpAmka9FJu0eDXcEzMqYuO4caLagjPTVzQIRUHFccWPduuaFU
            RPqQWtUDIspYLbCYlcdowXauNVSQfDpYcydHCQdpF0fUokJy8eldnhYMqzq3x7Xc
            Dx4nvwvLkSFbdcLB/TZw5TJkSFwPE3728MCHbOQh+2uxVwOsvT/yVfJm6arSbP/g
            YHXFDWuAORacYqCIbwIDAQABMA0GCSqGSIb3DQEBCwUAA4ICAQAjiLO5H+pcxXdp
            UXDCZViJTPH2kappLplsZruoYdsLkxjRQuS9SvBZc/KbZ9SOFR0WJ/Tz1QgpacPo
            tAoO0VONDx4zZE1sEwgQ217xUMzbXiZz3qd2u24/JMzvwNuKTmqRYFlEK1HKulCg
            DsjoQRc4IBVL3HNrjabyVcoSlec+E5uTnDMSBmd9nOBI7AyBwFcKgLyqtWLtgol/
            ujSVz/76b7UhJoq2Rf7l9tPv8C3ZVLjaq9xN2sKnsfnlLe0qaDtWVG8pm21D+cPl
            YBvCFj27LPBJLmHnU3oe48wLMX6BCImwHciG0hLCJKJ049VjSpJPk5z8S+OQKPGy
            jFDguO/4dAH8WfnC9RNbewF37MkbGGFZT8SlXnFQ+1pKc+AWZbu6LyX3qlVEQjqp
            HwuifXrJd5w0EcCK54J2mKfexM8dKLsQM9EcSNBsYRNUAOtcpNN3tuCjCYNUoqlK
            AjhPMS6EzGM+R55yVSjc4KoJgCoTCRfRs+o4YoE6xB1FlW5XdD1AJAHELTmAip+g
            HII1nNzBidzGd/kCw5+zIUWTV1F8uF3vyeWR+G6YzDnP+b5ojK4VsXs+L+0P8WWw
            SKvIeq9zqIDgseMsGuHEB5pu5rDSTmNVkvJLBb8yjwA47vwRb2c/omRdi9LTO6hn
            ySyPIxx7CcIaBN3MhqC4ckh1E0KftQ==
            -----END CERTIFICATE-----
        secret:
          path: "{{ project_agent_key_file }}"
          owner: "{{ zabbix_agent_user }}"
          group: "{{ zabbix_agent_group }}"
          mode: "0600"
          key: |
            -----BEGIN RSA PRIVATE KEY-----
            MIIEpQIBAAKCAQEAvI0PDY+/LTUuNmpGjtuReEWtuCLIpTifrmWZhy8WBfrVLpdv
            vQAvVT0X4qeZACH78yDLUwWpA0M1eEYz2TLJP4fh/M6VFE6V0rJo+aCMfosGWUMr
            oe00Y6UvhyTQmgkzh18dVulIy3S5fuXzLrzdpAmka9FJu0eDXcEzMqYuO4caLagj
            PTVzQIRUHFccWPduuaFURPqQWtUDIspYLbCYlcdowXauNVSQfDpYcydHCQdpF0fU
            okJy8eldnhYMqzq3x7XcDx4nvwvLkSFbdcLB/TZw5TJkSFwPE3728MCHbOQh+2ux
            VwOsvT/yVfJm6arSbP/gYHXFDWuAORacYqCIbwIDAQABAoIBAQCe8BkcSWvR495M
            qFFJ4vRA+htx+IBCJfUUwTglqB9ccxB48daS7zD3HUShHr3uSrdjPuWl2kOaKHFO
            LX9PO2xBTX3F6S3prETHEvVCV3+WvAJiBCknmhhrVrc1qGbfMZpqJldJB+UA/CfR
            PG09nJ8Iw8gByq3oXGP0CAPsUgDu04JsLBOJpScer1j+GtwF+1KeYM5lcSfgTYK6
            sf9pjCA24XWT9vdt76ayoaJnzDQ77JAS0mE/E5wBeJKXFFac246PZuJiRMlmh/uv
            CGIq37CvV/WHVhfWkBmOTFDMGLFiBxhOAFJKrcrfJNqz359R2a6hNa0BJESu6ORq
            cA4/j9IBAoGBAPl9Ir698rQzMD1ea8eLhSoJmh217Zd3oepQO/uJuf6J6AJrPnhi
            fb/isvIierUNsohFj8aW+fjlSmvy5Q5GKgTOM3IOAUpXvJWXvC+6uf4cngqw2rh4
            fxska8nFGrpAURpxjj40Lbnj7Qnt7pKMrBIu2C2eaMno34gsdHdN8cFBAoGBAMF4
            ylj/MVGnVQ3f/TCnTWqC+E5/L5wbulI6NKzY/yz8RrLPPP7OAWhTDb5RMxXiC3nR
            WvxMZVwqEmK4mQv1IpbJSm1fXzTgu2UY3nIrr+flq9IkfvifNN5KlAYmgZzIXeUE
            /xdVB9vXanodMW6FGi6S6yZMTfDqK3STs+FtJS2vAoGBAPj0stgtiWPh9JA4iUp8
            4evZ2w0svqK3wT2kxMYzYAMsr/TB+Xt9pMf2uuQ+Hb5PpcivyVG81EJW45WmsoU0
            5LcY4GM+sHDz7f5EhIgIR5LYEajPY+JSc1utU1XrNsmGZqgBipRt0vc9Bwsyfy+D
            6izWy+dxvFVG6M/ktG9cuxJBAoGAJ9v45Ej/IjF1RnyFL0boni8JdTKi3migBFzV
            iV7Tg7Md5azohh5vD808oZ8dBT8i2iAVvLEImOpaC1i4v0vrqmEiIlJpzP0X3oY3
            HhJ+FSquMYcvWY2DWODIilPYlDJ7lblnzKjKC7LfzvTAwGJPuJSwOZ2y2RWFimj7
            wE+6PyUCgYEAmxYRvzpChBqSOdfX/IAMTJHYJ0D8QaM0OHykwLpflQL+HwaAEUPJ
            Z35sqvkl1hN0L/RABA2vbYRKpDhqJpIiM2Ff0RN2s4mO/eFShfwOrWo4KObTFUzV
            eQlLeaYnzV5csXaKTi+XBXU+VqrZBvpY27APRmb7JJWl3mgnwSnPjyg=
            -----END RSA PRIVATE KEY-----

    # _______________________________________________postgresql
    postgresql_initial_password: password
    postgresql_debug: yes
    os_sysctl:
      FreeBSD: {}
      OpenBSD:
        # for postgresql
        kern.seminfo.semmni: 60
        kern.seminfo.semmns: 1024

        # zabbix server fails to start:
        # cannot initialize configuration cache: cannot get private shared
        # memory of size 8388608 for configuration cache: [12] Cannot allocate
        # memory
        #
        # cannot initialize database cache: cannot get private shared memory
        # of size 16777216 for history cache
        kern.shminfo.shmmax: 51200000
      Debian: {}
      RedHat: {}
    sysctl: "{{ os_sysctl[ansible_os_family] }}"

    os_postgresql_extra_packages:
      FreeBSD:
        - "databases/postgresql{{ postgresql_major_version }}-contrib"
      OpenBSD:
        - postgresql-contrib
      Debian:
        - postgresql-contrib
      RedHat:
        - "postgresql{{ postgresql_major_version }}-contrib"

    postgresql_extra_packages: "{{ os_postgresql_extra_packages[ansible_os_family] }}"
    postgresql_pg_hba_config: |
      host    all             all             127.0.0.1/32            {{ postgresql_default_auth_method }}
      host    all             all             ::1/128                 {{ postgresql_default_auth_method }}
      local   replication     all                                     trust
      host    replication     all             127.0.0.1/32            trust
      host    replication     all             ::1/128                 trust
    postgresql_config: |
      {% if ansible_os_family == 'Debian' %}
      data_directory = '{{ postgresql_db_dir }}'
      hba_file = '{{ postgresql_conf_dir }}/pg_hba.conf'
      ident_file = '{{ postgresql_conf_dir }}/pg_ident.conf'
      external_pid_file = '/var/run/postgresql/{{ postgresql_major_version }}-main.pid'
      port = 5432
      max_connections = 100
      unix_socket_directories = '/var/run/postgresql'
      ssl = on
      ssl_cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
      ssl_key_file = '/etc/ssl/private/ssl-cert-snakeoil.key'
      shared_buffers = 128MB
      dynamic_shared_memory_type = posix
      log_line_prefix = '%m [%p] %q%u@%d '
      log_timezone = 'UTC'
      cluster_name = '{{ postgresql_major_version }}/main'
      stats_temp_directory = '/var/run/postgresql/{{ postgresql_major_version }}-main.pg_stat_tmp'
      datestyle = 'iso, mdy'
      timezone = 'UTC'
      lc_messages = 'C'
      lc_monetary = 'C'
      lc_numeric = 'C'
      lc_time = 'C'
      default_text_search_config = 'pg_catalog.english'
      include_dir = 'conf.d'
      password_encryption = {{ postgresql_default_auth_method }}
      {% else %}
      max_connections = 100
      shared_buffers = 128MB
      dynamic_shared_memory_type = posix
      max_wal_size = 1GB
      min_wal_size = 80MB
      log_destination = 'syslog'
      log_timezone = 'UTC'
      update_process_title = off
      datestyle = 'iso, mdy'
      timezone = 'UTC'
      lc_messages = 'C'
      lc_monetary = 'C'
      lc_numeric = 'C'
      lc_time = 'C'
      default_text_search_config = 'pg_catalog.english'
      password_encryption = {{ postgresql_default_auth_method }}
      {% endif %}
    postgresql_users:
      - name: "{{ zabbix_server_backend_database_user }}"
        password: "{{ zabbix_server_backend_database_password }}"
        role_attr_flags: CREATEDB

    postgresql_databases: []

    project_postgresql_initdb_flags: --encoding=utf-8 --lc-collate=C --locale=en_US.UTF-8
    project_postgresql_initdb_flags_pwfile: "--pwfile={{ postgresql_initial_password_file }}"
    project_postgresql_initdb_flags_auth: "--auth-host={{ postgresql_default_auth_method }} --auth-local={{ postgresql_default_auth_method }}"
    os_postgresql_initdb_flags:
      FreeBSD: "{{ project_postgresql_initdb_flags }} {{ project_postgresql_initdb_flags_pwfile }} {{ project_postgresql_initdb_flags_auth }}"
      OpenBSD: "{{ project_postgresql_initdb_flags }} {{ project_postgresql_initdb_flags_pwfile }} {{ project_postgresql_initdb_flags_auth }}"
      RedHat: "{{ project_postgresql_initdb_flags }} {{ project_postgresql_initdb_flags_pwfile }} {{ project_postgresql_initdb_flags_auth }}"
      # XXX you cannot use --auth-host or --auth-local here because
      # pg_createcluster, which is executed during the installation, overrides
      # them, forcing md5
      Debian: "{{ project_postgresql_initdb_flags }} {{ project_postgresql_initdb_flags_pwfile }}"

    postgresql_initdb_flags: "{{ os_postgresql_initdb_flags[ansible_os_family] }}"
    os_postgresql_flags:
      FreeBSD: |
        postgresql_flags="-w -s -m fast"
      OpenBSD: ""
      Debian: ""
      RedHat: ""
    postgresql_flags: "{{ os_postgresql_flags[ansible_os_family] }}"

    # _______________________________________________nginx
    nginx_flags: -q
    nginx_config: |
      {% if ansible_os_family == 'Debian' or ansible_os_family == 'RedHat' %}
      user {{ nginx_user }};
      pid /run/nginx.pid;
      {% endif %}
      worker_processes 1;
      error_log {{ nginx_error_log_file }};
      events {
        worker_connections 1024;
      }
      http {
        include {{ nginx_conf_dir }}/mime.types;
        include {{ nginx_conf_fragments_dir }}/foo.conf;
        access_log {{ nginx_access_log_file }};
        default_type application/octet-stream;
        sendfile on;
        keepalive_timeout 65;
        server {
          listen 80;
          server_name localhost;
          root {{ zabbix_frontend_web_root }};
          location / {
            index index.html index.php;
          }
          # see https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/
          location ~ [^/]\.php(/|$) {
            fastcgi_split_path_info ^(.+?\.php)(/.*)$;
            if (!-f $document_root$fastcgi_script_name) {
              return 404;
            }
            fastcgi_param HTTP_PROXY "";
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            {% if ansible_os_family == 'OpenBSD' %}
            # XXX nginx on OpenBSD chroot's in /var/www
            fastcgi_param SCRIPT_FILENAME /var/www$document_root$fastcgi_script_name;
            {% else %}
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            {% endif %}
            fastcgi_intercept_errors on;
            include {{ nginx_conf_dir }}/fastcgi_params;
          }
          error_page 500 502 503 504 /50x.html;
          location = /50x.html {
          }
        }
      }
    nginx_config_fragments:
      - name: foo.conf
        config: "# FOO"
        state: present
    nginx_extra_packages_by_os:
      FreeBSD: []
      OpenBSD: []
      Debian:
        - nginx-extras
      RedHat: []
    nginx_extra_packages: "{{ nginx_extra_packages_by_os[ansible_os_family] }}"
    redhat_repo:
      epel:
        mirrorlist: "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-{{ ansible_distribution_major_version }}&arch={{ ansible_architecture }}"
        gpgcheck: yes
        enabled: yes

    nginx_htpasswd_users: []

    # _______________________________________________zabbix_frontend
    # default account: Admin
    # default password: see zabbix_server_api_login_password
    zabbix_frontend_config: |
      // Zabbix GUI configuration file.

      $DB['TYPE']				= '{{ zabbix_server_backend_database | upper }}';
      $DB['SERVER']			= '{{ zabbix_server_backend_database_host }}';
      $DB['PORT']				= '0';
      $DB['DATABASE']			= '{{ zabbix_server_backend_database_name }}';
      $DB['USER']				= '{{ zabbix_server_backend_database_user }}';
      $DB['PASSWORD']			= '{{ zabbix_server_backend_database_password }}';

      // Schema name. Used for PostgreSQL.
      $DB['SCHEMA']			= '';

      // Used for TLS connection.
      $DB['ENCRYPTION']		= false;
      $DB['KEY_FILE']			= '';
      $DB['CERT_FILE']		= '';
      $DB['CA_FILE']			= '';
      $DB['VERIFY_HOST']		= false;
      $DB['CIPHER_LIST']		= '';

      // Vault configuration. Used if database credentials are stored in Vault secrets manager.
      $DB['VAULT_URL']		= '';
      $DB['VAULT_DB_PATH']	= '';
      $DB['VAULT_TOKEN']		= '';

      // Use IEEE754 compatible value range for 64-bit Numeric (float) history values.
      // This option is enabled by default for new Zabbix installations.
      // For upgraded installations, please read database upgrade notes before enabling this option.
      $DB['DOUBLE_IEEE754']	= true;

      $ZBX_SERVER				= 'localhost';
      $ZBX_SERVER_PORT		= '10051';
      $ZBX_SERVER_NAME		= 'my zabbix';

      $IMAGE_FORMAT_DEFAULT	= IMAGE_FORMAT_PNG;

      // Uncomment this block only if you are using Elasticsearch.
      // Elasticsearch url (can be string if same url is used for all types).
      //$HISTORY['url'] = [
      //	'uint' => 'http://localhost:9200',
      //	'text' => 'http://localhost:9200'
      //];
      // Value types stored in Elasticsearch.
      //$HISTORY['types'] = ['uint', 'text'];

      // Used for SAML authentication.
      // Uncomment to override the default paths to SP private key, SP and IdP X.509 certificates, and to set extra settings.
      //$SSO['SP_KEY']			= 'conf/certs/sp.key';
      //$SSO['SP_CERT']			= 'conf/certs/sp.crt';
      //$SSO['IDP_CERT']		= 'conf/certs/idp.crt';
      //$SSO['SETTINGS']		= [];
    # _______________________________________________php_fpm
    php_additional_packages_map:
      FreeBSD:
        - "archivers/php{{ php_version_without_dot }}-zip"
        - "textproc/php{{ php_version_without_dot }}-xsl"
        - "databases/php{{ php_version_without_dot }}-pgsql"
      OpenBSD:
        - "php-zip%{{ php_version }}"
        - "php-xsl%{{ php_version }}"
        - "php-pgsql%{{ php_version }}"
      Debian:
        - "php{{ php_version }}-zip"
        - "php{{ php_version }}-xsl"
        - "php{{ php_version }}-pgsql"
    php_additional_packages: "{{ php_additional_packages_map[ansible_os_family] }}"

    php_ini_config: |
      [PHP]
      engine = On
      short_open_tag = Off
      precision = 14
      output_buffering = 4096
      zlib.output_compression = Off
      implicit_flush = Off
      unserialize_callback_func =
      serialize_precision = -1
      disable_functions =
      disable_classes =
      zend.enable_gc = On
      expose_php = On
      max_execution_time = 30
      max_input_time = 60
      memory_limit = 128M
      error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
      display_errors = Off
      display_startup_errors = Off
      log_errors = On
      log_errors_max_len = 1024
      ignore_repeated_errors = Off
      ignore_repeated_source = Off
      report_memleaks = On
      html_errors = On
      variables_order = "GPCS"
      request_order = "GP"
      register_argc_argv = Off
      auto_globals_jit = On
      post_max_size = 8M
      auto_prepend_file =
      auto_append_file =
      default_mimetype = "text/html"
      default_charset = "UTF-8"
      doc_root =
      user_dir =
      enable_dl = Off
      file_uploads = On
      upload_max_filesize = 2M
      max_file_uploads = 20
      allow_url_fopen = On
      allow_url_include = Off
      default_socket_timeout = 60

      ; for zabbix
      ; see https://www.zabbix.com/documentation/current/manual/installation/frontend
      post_max_size = 16M
      max_execution_time = 300
      max_input_time = 300

      {% if ansible_os_family == 'OpenBSD' %}
      date.timezone = "UTC"
      extension=gd.so
      extension=pgsql.so
      extension=xsl.so
      extension=zip.so
      {% endif %}

      [CLI Server]
      cli_server.color = On

    php_fpm_config: |
      [global]
      pid = {{ php_fpm_pid_file }}
      error_log = {{ php_fpm_log_dir }}/php-fpm.log
      include = {{ php_fpm_pool_dir }}/*.conf
    php_fpm_pool_config:
      - name: www
        content: |
          [www]
          user = {{ php_fpm_user }}
          group = {{ php_fpm_group }}
          listen = 127.0.0.1:9000
          pm = dynamic
          pm.max_children = 10
          pm.start_servers = 2
          pm.min_spare_servers = 1
          pm.max_spare_servers = 3
          access.log = {{ php_fpm_log_dir }}/access.log
```

# License

```
Copyright (c) 2021 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
