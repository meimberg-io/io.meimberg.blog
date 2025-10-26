# Bedrock WordPress for blog.meimberg.io — Docker, Ansible, CI/CD

## Project Plan (Archive)

This document contains the original implementation plan. All tasks have been completed.

### Decisions

- Stack: Bedrock (composer) + PHP 8.3 FPM + Nginx + MariaDB 10.11
- Orchestration: docker-compose (dev/prod); Traefik for prod routing (TLS via le)
- Secrets: `.env` locally (gitignored); GitHub Secrets for CI; optional Ansible for prod provisioning
- Backups: DB dumps + uploads to mounted backup dir via cron (Ansible)
- SMTP: central postfix relay container managed in Ansible; WordPress via SMTP plugin
- Environments: dev (localhost:8080), prod (`blog.meimberg.io`)

### Implementation Status

✅ All tasks completed:
- [x] Scaffold Bedrock app and repo structure in io.meimberg.blog
- [x] Create dev docker-compose (php, nginx, mariadb, wp-cli)
- [x] Create prod compose with Traefik labels and volumes
- [x] Implement PHP-FPM and Nginx Dockerfiles with app copy
- [x] Write Nginx config for Bedrock and PHP-FPM
- [x] Author .env.example for Bedrock, DB, SMTP, salts
- [x] Add CI to build/push images and deploy via SSH
- [x] Initialize custom theme folder and composer plugin config
- [x] Complete documentation (README, GITHUB-SETUP)

### Architecture Overview

**Development:**
- Services: `db:mariadb:10.11`, `php`, `nginx`, `wpcli`
- Port: `8080:80`
- Volumes: bind-mount `bedrock/`, named volume for `db-data`

**Production:**
- Fixed container names: `blog-nginx`, `blog-php`, `blog-db`
- No exposed ports (Traefik network routing)
- Volumes: `blog-uploads`, `blog-data`, `/srv/backups/blog`
- Networks: `blog` (internal), `traefik` (external)

### Key Files

- `docker-compose.yml` - Development environment
- `docker-compose.prod.yml` - Production deployment
- `.github/workflows/deploy.yml` - CI/CD pipeline
- `docker/php/Dockerfile` - PHP-FPM container
- `docker/nginx/Dockerfile` - Nginx container
- `docker/nginx/nginx.conf` - Nginx configuration

### Deployment Flow

1. Push to `main` branch
2. GitHub Actions builds PHP and Nginx images
3. Images pushed to GitHub Container Registry
4. SSH to server, write `.env` from secrets
5. Deploy containers with Traefik labels
6. Blog live at https://blog.meimberg.io

### Notes

- Bedrock installed properly via Docker Composer (clean approach)
- WordPress core managed via Composer
- Plugins/themes via Composer or WordPress admin
- Production secrets via GitHub Secrets
- No port conflicts (documented in port registry)
