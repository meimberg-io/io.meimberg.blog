#!/bin/sh
set -e

# Start cron daemon
crond -b -l 2

# Execute the main command (php-fpm)
exec "$@"

