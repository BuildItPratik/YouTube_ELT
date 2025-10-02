#!/bin/bash

set -e
set -u

function create_user_and_database() {
    local database="$1"
    local username="$2"
    local password="$3"

    echo "Creating user '$username' and database '$database'..."

    # Use ON_ERROR_STOP=0 to continue if user or database already exists
    psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" <<-EOSQL
        -- Create user if it doesn't exist
        DO
        \$\$
        BEGIN
            IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$username') THEN
                CREATE USER "$username" WITH PASSWORD '$password';
            END IF;
        END
        \$\$;

        -- Grant privileges only if database exists
        GRANT ALL PRIVILEGES ON DATABASE "$database" TO "$username";
EOSQL

    # Create database if it doesn't exist
    psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" <<-EOSQL
        CREATE DATABASE "$database";
EOSQL

    echo "  User '$username' and database '$database' created (or already existed)."
}

# Create databases
create_user_and_database "$METADATA_DATABASE_NAME" "$METADATA_DATABASE_USERNAME" "$METADATA_DATABASE_PASSWORD"
create_user_and_database "$CELERY_BACKEND_NAME" "$CELERY_BACKEND_USERNAME" "$CELERY_BACKEND_PASSWORD"
create_user_and_database "$ELT_DATABASE_NAME" "$ELT_DATABASE_USERNAME" "$ELT_DATABASE_PASSWORD"

echo "✅ All databases and users created successfully."
