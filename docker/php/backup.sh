#!/bin/sh
set -e

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup"

echo "[$(date)] Starting blog backup..."

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Clean old exports (keep last backup)
rm -f "${BACKUP_DIR}"/db_*.sql.gz
rm -f "${BACKUP_DIR}"/uploads_*.tar.gz

# Dump database
echo "[$(date)] Dumping database..."
mysqldump -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" \
  --single-transaction --quick --lock-tables=false \
  > "${BACKUP_DIR}/db_${DATE}.sql"

gzip "${BACKUP_DIR}/db_${DATE}.sql"

# Archive uploads
echo "[$(date)] Archiving uploads..."
if [ -d "/var/www/html/web/app/uploads" ]; then
  tar czf "${BACKUP_DIR}/uploads_${DATE}.tar.gz" \
    -C /var/www/html/web/app uploads/
fi

echo "[$(date)] Blog backup completed: db_${DATE}.sql.gz, uploads_${DATE}.tar.gz"

