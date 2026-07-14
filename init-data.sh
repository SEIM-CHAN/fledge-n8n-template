#!/bin/bash
set -e

if [ -n "${POSTGRES_NON_ROOT_USER:-}" ] && [ -n "${POSTGRES_NON_ROOT_PASSWORD:-}" ]; then
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DO
    \$\$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${POSTGRES_NON_ROOT_USER}') THEN
        EXECUTE format('CREATE USER %I WITH PASSWORD %L', '${POSTGRES_NON_ROOT_USER}', '${POSTGRES_NON_ROOT_PASSWORD}');
      END IF;
    END
    \$\$;

    GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_NON_ROOT_USER};
    GRANT USAGE, CREATE ON SCHEMA public TO ${POSTGRES_NON_ROOT_USER};

    CREATE TABLE IF NOT EXISTS leads (
      id BIGSERIAL PRIMARY KEY,
      platform TEXT NOT NULL,
      dm_thread_id TEXT NOT NULL UNIQUE,
      customer_name TEXT,
      customer_handle TEXT,
      status TEXT NOT NULL DEFAULT 'new',
      interest_summary TEXT,
      last_message_at TIMESTAMPTZ,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS conversations (
      id BIGSERIAL PRIMARY KEY,
      lead_id BIGINT NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
      role TEXT NOT NULL,
      message_text TEXT NOT NULL,
      meta_json JSONB NOT NULL DEFAULT '{}'::jsonb,
      sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE INDEX IF NOT EXISTS idx_conversations_lead_id_sent_at
      ON conversations (lead_id, sent_at DESC);

    CREATE TABLE IF NOT EXISTS lead_notifications (
      id BIGSERIAL PRIMARY KEY,
      lead_id BIGINT NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
      notification_type TEXT NOT NULL,
      payload_json JSONB NOT NULL DEFAULT '{}'::jsonb,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
EOSQL
else
  echo "SETUP INFO: No environment variables given for non-root user creation."
fi
