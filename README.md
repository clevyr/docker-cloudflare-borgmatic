# docker-cloudflare-borgmatic

[![Docker Build](https://github.com/clevyr/docker-cloudflare-borgmatic/actions/workflows/docker.yml/badge.svg)](https://github.com/clevyr/docker-cloudflare-borgmatic/actions/workflows/docker.yml)

Backup every Cloudflare zone with Borg and Borgmatic.

## Pull Command

```sh
docker pull ghcr.io/clevyr/cloudflare-borgmatic
```

## Config

### Cloudflare Authentication

Each zone is exported by [flarectl](https://github.com/cloudflare/cloudflare-go/tree/master/cmd/flarectl). To authenticate into Cloudflare, generate an [API token](https://dash.cloudflare.com/profile/api-tokens) with `Zone:Read` and `DNS:Read` permission.

| Variable       | Description                     |
|----------------|---------------------------------|
| `CF_API_TOKEN` | Cloudflare API token             |

### Borgmatic

All [Borg environment variables](https://borgbackup.readthedocs.io/en/stable/usage/general.html#environment-variables) are supported.

Your [Borgmatic](https://torsion.org/borgmatic/) config should be volume bound to `/etc/borgmatic/config.yaml`

Example Borgmatic config:
```yaml
location:
  repositories:
    - /out/borg # Borg repo goes here
  source_directories:
    - /data
storage:
  archive_name_format: "cloudflare-{now:%Y-%m-%d-%H%M%S}"
retention:
  keep_hourly: 168
  keep_daily: 31
  keep_monthly: 24
  keep_yearly: 2
  prefix: "cloudflare-"
consistency:
  check_last: 3
  prefix: "cloudflare-"
```