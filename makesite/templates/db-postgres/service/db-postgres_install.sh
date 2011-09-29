#!/bin/bash

# Import BSFL
PROJECT_SERVICEDIR={{ project_servicedir }}
source $PROJECT_SERVICEDIR/.bsfl

# Variables
PGUSER={{ pguser }}
PGPASSWORD={{ pgpassword }}
PGHOST={{ pghost }}
PGPORT={{ pgport }}
PSQL="psql -At"
DBNAME={{ dbname }}
DBUSER={{ dbuser }}
DBPASSWORD={{ dbpassword }}

check_program psql

if [ -z "$PGUSER" ] || [ -z $PGHOST ] || [ -z $PGPASSWORD ]; then
    # pass
    msg_warning "postgres some data not defined."
    exit 0
fi

export PGUSER=$PGUSER
export PGPASSWORD=$PGPASSWORD
export PGHOST=$PGHOST
export PGPORT=$PGPORT

SQL_CREATE_DB="create database $DBNAME with owner $DBUSER"
SQL_CREATE_ROLE="create role $DBUSER with login password '$DBPASSWORD'"
SQL_CHECK_DB="select count(1) from pg_catalog.pg_database where datname = '$DBNAME' "

_check_db_exist () {
    $PSQL -c "$SQL_CHECK_DB"
}

_create_role () {
    echo "  * Create user '$DBUSER'."
    $PSQL -c "$SQL_CREATE_ROLE"
}

_create_db () {
    echo "  * Create database '$DBNAME'."
    $PSQL -c "$SQL_CREATE_DB"
}

if [ $(_check_db_exist) -eq 0 ]; then
    _create_role
    _create_db
else
    msg_warning "Database '$DBNAME' exist"
fi
