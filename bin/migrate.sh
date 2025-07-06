#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Apply Alembic migrations so the dev DB schema is up-to-date.
# Safe to run multiple times – Alembic is idempotent.
# ---------------------------------------------------------------------------

set -euo pipefail

COMPOSE_FILE=${COMPOSE_FILE:-./infra/local/docker-compose.db.yaml}
SERVICE_NAME=${DB_SERVICE:-db}
CONTAINER_NAME=${DB_CONTAINER:-fastapi_db_dev}

# ----------------------------------------------------------------------------
# Spin up Postgres (detached) if it's not already running
# ----------------------------------------------------------------------------
echo "🛠️  Ensuring Postgres container is running …"
docker compose -f "$COMPOSE_FILE" up -d "$SERVICE_NAME"

# ----------------------------------------------------------------------------
# Wait until Docker health-check says “healthy”
# ----------------------------------------------------------------------------
echo "⏳ Waiting for Postgres to pass its health-check …"
until [ "$(docker inspect -f '{{.State.Health.Status}}' "$CONTAINER_NAME")" = "healthy" ]; do
  sleep 1
done
echo "✅ Postgres is healthy."

# ----------------------------------------------------------------------------
# Load environment variables and run Alembic
# ----------------------------------------------------------------------------
if [ -f ".env" ]; then
  # Export all vars from .env into the shell environment for Alembic
  set -a; source .env; set +a
fi

echo "🚀 Applying Alembic migrations (alembic upgrade head) …"
alembic upgrade head
echo "🎉 Database schema is now current."
