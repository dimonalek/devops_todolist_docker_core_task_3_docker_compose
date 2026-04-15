#!/bin/sh
# wait_for_db.sh — polls MySQL until it accepts connections, then runs
# Django migrations and starts the development server.

set -e

HOST="${MYSQL_HOST:-db}"
PORT="${MYSQL_PORT:-3306}"
USER="${MYSQL_USER:-app_user}"
PASSWORD="${MYSQL_PASSWORD:-1234}"

echo "Waiting for MySQL at $HOST:$PORT ..."

until mysqladmin ping -h "$HOST" -P "$PORT" -u "$USER" -p"$PASSWORD" --silent 2>/dev/null; do
  echo "  MySQL is not ready yet — retrying in 3 s..."
  sleep 3
done

echo "MySQL is ready. Running migrations..."
python manage.py migrate --noinput

echo "Starting Django development server..."
exec python manage.py runserver 0.0.0.0:8080
