#!/usr/bin/env bash

set -e

# Default values
MMS_USERNAME="admin"
ENVIRONMENT="dev"

# Script directory
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Source .env file if it exists
if test -e "$SCRIPTPATH/../.env"; then
    source "$SCRIPTPATH/../.env"
fi

# Source .env file if it exists
if test -e "$SCRIPTPATH/.env"; then
    source "$SCRIPTPATH/.env"
fi

usage() {
    echo "Usage: $0 [options] -p password -f excel_file"
    echo "Options:"
    echo "  -u username   Username for authentication (default: admin)"
    echo "  -p password   Password for authentication (required)"
    echo "  -f file      Excel file to transform (required)"
    echo "  --env env    Environment (dev/staging default: dev)"
    echo "  -h           Show this help message"
    exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -u|--username) MMS_USERNAME="$2"; shift ;;
        -p|--password) MMS_PASSWORD="$2"; shift ;;
        -f|--file) EXCEL_FILE="$2"; shift ;;
        --env) ENVIRONMENT="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

# Validate required parameters
if [ -z "$MMS_PASSWORD" ]; then
    echo "Error: Password (-p) is required"
    usage
fi

if [ -z "$EXCEL_FILE" ]; then
    echo "Error: Excel file (-f) is required"
    usage
fi

if [ ! -f "$EXCEL_FILE" ]; then
    echo "Error: Excel file '$EXCEL_FILE' does not exist"
    exit 1
fi

# Validate environment
if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "staging" ]; then
    echo "Error: Invalid environment '$ENVIRONMENT'. Valid values are: dev, staging"
    exit 1
fi

if test "$ENVIRONMENT" == "staging"; then
  LOGIN_URL="https://mms-staging.squadc.com/mmsapi/v1/auth/login"
  TRANSFORM_URL="https://mms-staging.squadc.com/mmsapi/v1/development/referencedata/transform"
else
  LOGIN_URL="http://localhost:8080/api/v2/auth/login"
  TRANSFORM_URL="http://localhost:3333/development/referencedata/transform"
fi

# Get authentication token
TOKEN=$(curl --fail-with-body -H "Content-Type: application/json" -s \
  -X POST "$LOGIN_URL" \
  -d "{\"username\":\"${MMS_USERNAME}\",\"password\":\"${MMS_PASSWORD}\"}"|jq -r .token)

# Transform excel file
curl -H "Authorization: Bearer $TOKEN" -s \
  -F "file=@$EXCEL_FILE" \
  "$TRANSFORM_URL"|jq .
