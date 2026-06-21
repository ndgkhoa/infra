#!/bin/bash
# Runs once on first Postgres init (empty data dir). Creates the Authentik
# database. Add more project databases here as you onboard them.
set -euo pipefail

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-'EOSQL'
  SELECT 'CREATE DATABASE authentik_dev'
   WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'authentik_dev')\gexec
EOSQL
