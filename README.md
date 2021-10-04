# `trombik.zabbix_server`

Manage `zabbix` server.

## Notes for all users

The role does not support `MySQL`.

The role overrides the default login password of `Admin`, which can be
controlled by `zabbix_server_api_login_password`.

## Notes for FreeBSD users

The role does not work out of box because `zabbix-api` port is not in the
official FreeBSD ports tree. My `py-zabbix-api` is available at
[`trombik/freebsd-ports-py-zabbix-api`](https://github.com/trombik/freebsd-ports-py-zabbix-api).

## Notes for Debian users

The role installs `py-zabbix-api` with `pip` as root.

## Notes for OpenBSD users

The role installs `py-zabbix-api` with `pip` as root.

# Requirements

The roles requires `ansible` collections. See [`requirements.yml`](requirements.yml).

# Role Variables

| variable | description | default |
|----------|-------------|---------|


# Dependencies

None

# Example Playbook

```yaml
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
