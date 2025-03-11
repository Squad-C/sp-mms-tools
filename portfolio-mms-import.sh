#!/usr/bin/env bash

set -e

SOLAR_PLANIT_URL="http://localhost:8080"

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
    echo "Usage: $0 [options] -u URL -t API_TOKEN"
    echo "Options:"
    echo "  -u SOLAR_PLANIT_URL    (default: http://localhost:8080)"
    echo "  -t SP_IMPORT_API_TOKEN    Authentication token for solar planit (required)"
    echo "  -h           Show this help message"
    exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -u|--url) SOLAR_PLANIT_URL="$2"; shift ;;
        -t|--token) SP_IMPORT_API_TOKEN="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

# Validate required parameters
if [ -z "$SP_IMPORT_API_TOKEN" ]; then
    echo "Error: Authentication token (-t) is required"
    usage
fi


# Remove trailing slash from SOLAR_PLANIT_URL if present
SOLAR_PLANIT_URL="${SOLAR_PLANIT_URL%/}"
SP_IMPORT_URL="$SOLAR_PLANIT_URL/masterdata/portfolio/importItems"

# Transform excel file
curl -H "Authorization: Bearer $SP_IMPORT_API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST --data-binary @- \
  -k \
  "$SP_IMPORT_URL"
