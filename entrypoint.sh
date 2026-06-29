#!/usr/bin/env sh
# Container entrypoint: wait for the database, apply migrations,
# collect static files, then hand off to the CMD (daphne ASGI server).
set -e

if [ -n "$POSTGRES_DB" ]; then
    echo "Waiting for database at ${POSTGRES_HOST:-db}:${POSTGRES_PORT:-5432} ..."
    python - <<'PY'
import os, socket, sys, time

host = os.environ.get("POSTGRES_HOST", "db")
port = int(os.environ.get("POSTGRES_PORT", "5432"))
for _ in range(60):
    try:
        with socket.create_connection((host, port), timeout=2):
            print("Database is up.")
            sys.exit(0)
    except OSError:
        time.sleep(1)
sys.exit("Database not reachable after 60s")
PY
fi

echo "Applying migrations ..."
python manage.py migrate --noinput

echo "Collecting static files ..."
python manage.py collectstatic --noinput

exec "$@"
