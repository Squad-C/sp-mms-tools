#!/usr/bin/env bash

set -e

# Spinner function
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid > /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        echo -en "\b\b\b\b\b\b"
        sleep $delay
    done
    echo -en "\b\b\b\b\b\b"
}

# Cleanup function
cleanup() {
    # Kill the spinner
    if [ -n "$SPINNER_PID" ]; then
        kill $SPINNER_PID 2>/dev/null
    fi
}

# Set up trap
trap cleanup EXIT

# Default values
MMS_USERNAME="admin"
ENVIRONMENT="staging"
SOLAR_PLANIT_URL="http://localhost:8080"
BATCH_MODE=false

# Script directory
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Source .env file if it exists
if test -e "$SCRIPTPATH/../.env"; then
    source "$SCRIPTPATH/../.env"
fi

if test -e "$SCRIPTPATH/.env"; then
    source "$SCRIPTPATH/.env"
fi

usage() {
    echo "Usage: $0 [options] -p password -f excel_file -t token"
    echo "Options:"
    echo "  -u username   Username for authentication (default: admin)"
    echo "  -p password   Password for authentication (required)"
    echo "  -f file      Excel file to transform (required)"
    echo "  -t token     Authentication token for solar planit (required)"
    echo "  --url url    Solar-Planit URL (default: http://localhost:8080)"
    echo "  --env env    MMS Environment (dev/staging default: staging)"
    echo "  --batch-mode Disable spinner (useful for automated scripts)"
    echo "  -h           Show this help message"
    exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -u|--username) MMS_USERNAME="$2"; shift ;;
        -p|--password) MMS_PASSWORD="$2"; shift ;;
        -f|--file) EXCEL_FILE="$2"; shift ;;
        -t|--token) SP_IMPORT_API_TOKEN="$2"; shift ;;
        --url) SOLAR_PLANIT_URL="$2"; shift ;;
        --env) ENVIRONMENT="$2"; shift ;;
        --batch-mode) BATCH_MODE=true ;;
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

if [ -z "$SP_IMPORT_API_TOKEN" ]; then
    echo "Error: Authentication token (-t) is required"
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

# Execute transform-excel and pipe to portfolio-mms-import
echo "Processing Excel file..."
(
"$SCRIPTPATH/transform-excel.sh" \
    -u "$MMS_USERNAME" \
    -p "$MMS_PASSWORD" \
    -f "$EXCEL_FILE" \
    --env "$ENVIRONMENT" | \
"$SCRIPTPATH/portfolio-mms-import.sh" \
    -u "$SOLAR_PLANIT_URL" \
    -t "$SP_IMPORT_API_TOKEN"
) &

# Get the background process PID
PIPELINE_PID=$!

# Start the spinner if not in batch mode
if [ "$BATCH_MODE" = false ]; then
    spinner $PIPELINE_PID &
    SPINNER_PID=$!
fi

# Wait for the pipeline to complete
wait $PIPELINE_PID
