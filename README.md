# Blog.meimberg.io

Personal WordPress blog built with Bedrock, Docker, and modern deployment practices.

## Stack

- **Bedrock** - Modern WordPress boilerplate with Composer
- **PHP 8.3 FPM** - Application server (Alpine Linux)
- **Nginx** - Web server with optimized configuration
- **MariaDB 10.11** - Database
- **Docker Compose** - Development and production orchestration
- **Traefik** - Production load balancer with automatic SSL
- **GitHub Actions** - CI/CD pipeline

## Development

### Prerequisites
- Docker & Docker Compose
- Git

### Quick Start

1. Clone the repository
   ```bash
   git clone [repo-url]
   cd io.meimberg.blog
   ```

2. Start development environment
   ```bash
   docker compose up -d
   ```

3. Access WordPress
   - **Frontend:** http://localhost:8080
   - **Admin:** http://localhost:8080/wp/wp-admin

4. Install WordPress (first time only)
   - Navigate to http://localhost:8080
   - Follow WordPress installation wizard

### Development Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f

# Restart services
docker compose restart

# Run WP-CLI commands
docker compose run --rm wpcli wp --info

# Install a plugin via Composer
docker run --rm -v $(pwd):/app -w /app composer require wpackagist-plugin/plugin-name

# Install a theme via Composer
docker run --rm -v $(pwd):/app -w /app composer require wpackagist-theme/theme-name
```

### Project Structure

```
io.meimberg.blog/
├── bedrock/                 # Bedrock WordPress
│   ├── config/             # Environment configs
│   ├── web/                # Web root
│   │   ├── app/           # WordPress content
│   │   │   ├── mu-plugins/
│   │   │   ├── plugins/
│   │   │   ├── themes/    # Custom themes here
│   │   │   └── uploads/
│   │   └── wp/            # WordPress core (gitignored)
│   ├── vendor/            # Composer dependencies
│   └── composer.json      # PHP dependencies
├── docker/
│   ├── nginx/            # Nginx configuration
│   └── php/              # PHP-FPM configuration
├── .github/workflows/    # CI/CD pipeline
└── docker-compose.yml    # Development setup
```

### Theme Development

Custom themes go in `bedrock/web/app/themes/`:

```bash
# Create a new theme
mkdir -p bedrock/web/app/themes/my-theme
cd bedrock/web/app/themes/my-theme

# Create required files
touch style.css index.php functions.php
```

Activate your theme in WordPress admin or via WP-CLI:
```bash
docker compose run --rm wpcli wp theme activate my-theme
```

### Plugin Management

**Via Composer (recommended):**
```bash
# Search plugins
docker run --rm composer search wpackagist-plugin/plugin-name

# Install plugin
docker run --rm -v $(pwd)/bedrock:/app -w /app composer require wpackagist-plugin/plugin-name

# Update plugins
docker run --rm -v $(pwd)/bedrock:/app -w /app composer update
```

**Via WordPress Admin:**
Plugins installed via admin are stored in `bedrock/web/app/plugins/` (gitignored).
For production, add them via Composer.

## Production Deployment

See [GITHUB-SETUP.md](docs/GITHUB-SETUP.md) for complete deployment guide.

### Quick Summary

1. **Configure GitHub Secrets & Variables** (one time)
   - Set `APP_DOMAIN`, `SERVER_HOST`, WordPress salts, etc.

2. **Deploy via Git**
   ```bash
   git push origin main
   ```

3. **Automatic deployment** (4-5 minutes)
   - Builds Docker images
   - Deploys to server with Traefik
   - Available at https://blog.meimberg.io

### Production Architecture

```
Internet → Traefik (SSL termination)
    ↓
  Nginx (static files + proxy)
    ↓
  PHP-FPM (WordPress)
    ↓
  MariaDB (persistent data)
```

**Volumes:**
- `blog-data` - Database storage
- `blog-uploads` - WordPress media files
- `/srv/backups/blog` - Database backups

**Networks:**
- `blog` - Internal communication
- `traefik` - External access (shared with other services)

## Environment Variables

### Development (.env)
```bash
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=wordpress
DB_HOST=db
WP_ENV=development
WP_HOME=http://localhost:8080
WP_SITEURL=http://localhost:8080/wp
```

### Production
Managed via GitHub Secrets - see [GITHUB-SETUP.md](docs/GITHUB-SETUP.md)

## Troubleshooting

### Port 8080 already in use
```bash
# Change port in docker-compose.yml
ports:
  - "8081:80"  # Changed from 8080
```

### Permission issues
```bash
# Fix ownership
docker compose exec php chown -R www-data:www-data /var/www/html
```

### Database connection error
```bash
# Check database is running
docker compose ps

# View database logs
docker compose logs db

# Restart database
docker compose restart db
```

### Clear WordPress cache
```bash
docker compose run --rm wpcli wp cache flush
```

### Reset WordPress
```bash
# WARNING: This deletes all content!
docker compose down -v
docker compose up -d
# Visit http://localhost:8080 to reinstall
```

## Backups

The blog automatically exports its data to `/srv/backups/blog/` for the main Ansible backup system.

**What gets backed up:**
- Database dump (SQL)
- WordPress uploads

**Schedule:**
- **2:30 AM** - Blog exports to `/srv/backups/blog/`
- **3:00 AM** - Main Ansible backup archives everything to Storage Box

**Manual backup:**
```bash
# Production
ssh root@your-server
docker exec blog-php /usr/local/bin/backup.sh

# Check backup
ls -lh /srv/backups/blog/

# View backup log
docker exec blog-php cat /var/log/backup.log
```

**Restore from backup:**
```bash
# Extract backup
cd /tmp
tar -xzf /srv/backups/blog/backup_YYYYMMDD_HHMMSS.tar.gz

# Restore database
zcat db_YYYYMMDD_HHMMSS.sql.gz | docker exec -i blog-db mysql -u root -pPASSWORD wordpress

# Restore uploads
tar -xzf uploads_YYYYMMDD_HHMMSS.tar.gz -C /path/to/uploads/
```

## Security

- ✅ File editing disabled in production
- ✅ Security headers via Nginx
- ✅ HTTPS via Traefik (production)
- ✅ Environment-specific configurations
- ✅ Database credentials in secrets
- ✅ Regular automated backups

## Resources

- **Bedrock Documentation:** https://roots.io/bedrock/docs/
- **WordPress Packagist:** https://wpackagist.org/
- **Docker Compose:** https://docs.docker.com/compose/
- **Traefik:** https://doc.traefik.io/traefik/

## License

Private project