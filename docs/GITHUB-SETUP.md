# GitHub Setup

Initial configuration required for automatic deployment.

## GitHub Variables

**Settings → Variables → Actions**

| Name | Value | Description |
|------|-------|-------------|
| `APP_DOMAIN` | `blog.meimberg.io` | Application domain |
| `SERVER_HOST` | `hc-02.meimberg.io` | Server hostname |
| `SERVER_USER` | `deploy` | SSH user (optional, defaults to `deploy`) |
| `DB_NAME` | `wordpress` | Database name (optional, defaults to `wordpress`) |
| `DB_USER` | `wordpress` | Database user (optional, defaults to `wordpress`) |

## GitHub Secrets

**Settings → Secrets → Actions**

| Name | Value | Description |
|------|-------|-------------|
| `SSH_PRIVATE_KEY` | `<private key contents>` | Deploy user private key |
| `DB_PASSWORD` | `<secure password>` | Database password |
| `AUTH_KEY` | `<random 64 chars>` | WordPress auth key |
| `SECURE_AUTH_KEY` | `<random 64 chars>` | WordPress secure auth key |
| `LOGGED_IN_KEY` | `<random 64 chars>` | WordPress logged in key |
| `NONCE_KEY` | `<random 64 chars>` | WordPress nonce key |
| `AUTH_SALT` | `<random 64 chars>` | WordPress auth salt |
| `SECURE_AUTH_SALT` | `<random 64 chars>` | WordPress secure auth salt |
| `LOGGED_IN_SALT` | `<random 64 chars>` | WordPress logged in salt |
| `NONCE_SALT` | `<random 64 chars>` | WordPress nonce salt |

**Generate WordPress salts:**
Visit https://api.wordpress.org/secret-key/1.1/salt/ and copy each value.

**Get SSH private key:**
```bash
# Linux/Mac
cat ~/.ssh/id_rsa
# Or your deploy key: cat ~/.ssh/deploy_key

# Windows PowerShell
Get-Content C:\Users\YourName\.ssh\id_rsa
```

Copy entire output including `-----BEGIN` and `-----END` lines.

# DNS Configuration

**DNS is already configured** (confirmed by user)
```
blog.meimberg.io  →  A/CNAME  →  hc-02.meimberg.io
```

# Server Infrastructure

**Prerequisites (one-time setup):**

Run Ansible to setup server infrastructure:

```bash
cd ../io.meimberg.ansible

# Install Ansible collections
ansible-galaxy collection install -r requirements.yml

# Run infrastructure setup
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --vault-password-file vault_pass
```

**This installs:**
- ✅ Docker + Docker Compose
- ✅ Traefik reverse proxy (automatic SSL)
- ✅ `deploy` user (for deployments)
- ✅ Firewall rules (SSH, HTTP, HTTPS)
- ✅ Automated backups at `/srv/backups/blog`

**Server must be ready before first deployment!**

**Note:** Ansible automatically creates deploy user and configures SSH access.

# First Deployment

After completing all steps above:

```bash
git add .
git commit -m "Setup deployment"
git push origin main
```

**Monitor:** https://github.com/[your-org]/io.meimberg.blog/actions

**Deployment takes ~4-5 minutes:**
1. ✅ Builds PHP and Nginx Docker images
2. ✅ Pushes to GitHub Container Registry
3. ✅ SSHs to server
4. ✅ Creates deployment directory `/srv/blog.meimberg.io`
5. ✅ Writes `.env` file from secrets
6. ✅ Deploys containers with Traefik labels
7. ✅ Blog live at https://blog.meimberg.io

# Additional Information

## Checklist

Before first deployment:

- [x] DNS configured (confirmed)
- [ ] GitHub repo created (confirmed)
- [ ] GitHub Variables added: `APP_DOMAIN`, `SERVER_HOST`, `SERVER_USER`
- [ ] GitHub Secrets added: `SSH_PRIVATE_KEY`, `DB_PASSWORD`, WordPress salts (8 keys)
- [ ] Server infrastructure deployed via Ansible
- [ ] Can SSH to server: `ssh deploy@hc-02.meimberg.io`
- [ ] Backup directory exists: `/srv/backups/blog`

**Estimated setup time:** 20-25 minutes

## Port Registry (Traefik Network)

**Important:** All services run on Traefik network without exposed ports (except Traefik itself).

| Service | Container Names | Traefik Domain | Internal Port |
|---------|----------------|----------------|---------------|
| Blog | `blog-nginx`, `blog-php`, `blog-db` | `blog.meimberg.io` | 80 (nginx) |
| Strapi | `strapi`, `strapiDB` | `api.meimberg.io` | 1337 |
| Next.js | `nextjs` | `app.meimberg.io` | 3000 |

**No port conflicts** - Traefik routes by domain name.

## Troubleshooting

**GitHub Actions fails at deploy step:**
```bash
# Test SSH manually
ssh -i ~/.ssh/deploy_key deploy@hc-02.meimberg.io

# Check deploy user exists
ssh root@hc-02.meimberg.io "id deploy"
```

**Container not starting:**
```bash
ssh deploy@hc-02.meimberg.io "cd /srv/blog.meimberg.io && docker compose logs"
```

**SSL certificate issues:**
```bash
# Check Traefik logs
ssh root@hc-02.meimberg.io "docker logs traefik | grep blog"

# Verify DNS propagated
dig blog.meimberg.io +short
```

**Image pull failed:**
- Automatically handled via `GITHUB_TOKEN`
- If still failing, verify package permissions in GitHub

**Database connection issues:**
```bash
# Check database container
ssh deploy@hc-02.meimberg.io "docker logs blog-db"

# Check environment variables
ssh deploy@hc-02.meimberg.io "cd /srv/blog.meimberg.io && cat .env"
```

## Changing Domain

1. Update DNS record
2. Update GitHub Variable `APP_DOMAIN`
3. Push to trigger redeploy

No code changes needed!

## Database Backups

Backups are stored in `/srv/backups/blog/` on the server.

**Manual backup:**
```bash
ssh deploy@hc-02.meimberg.io "docker exec blog-db mysqldump -u wordpress -p wordpress > /backup/manual-$(date +%Y%m%d).sql"
```

**Automated backups** should be configured via Ansible cron/systemd timer.

## Related Documentation

- [README.md](README.md) - Development setup
- [../io.meimberg.ansible/README.md](../io.meimberg.ansible/README.md) - Ansible overview
- [../io.meimberg.ansible/docs/SETUP.md](../io.meimberg.ansible/docs/SETUP.md) - Server setup
- [../io.meimberg.ansible/docs/SSH-KEYS.md](../io.meimberg.ansible/docs/SSH-KEYS.md) - SSH key configuration
