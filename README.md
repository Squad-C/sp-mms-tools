# MMS Utility Scripts

This directory contains utility scripts for the MMS (Masterdata Management System) project. Below is documentation on
how to use each script and their use cases.

## General Setup

Ensure you have this commands installed:

- bash
- jq
- curl

Easiest way to work with these script is by using an .env file:
`cp .env.example .env`
and edit the variables inside.

Then you are able to import a portfolio from a reference data excel into Solar-Planit by running:

```
./excel-to-sp.sh -f REFERENCE_DATA.xlsx
```

### Environment Files

Several scripts source environment variables from `.env` files:

1. `.env` in the parent directory (optional)
2. `.env` in the bin directory (optional)

These files can be used to set default values for environment variables without having to pass them as command-line
arguments each time.

## excel-to-sp.sh

**Purpose**: Processes an Excel file and imports the data into Solar-Planit.

**Usage**:

```bash
./excel-to-sp.sh [options] -p password -f excel_file -t token
```

**Options**:

- `-u, --username`: Username for authentication (default: admin)
- `-p, --password`: Password for authentication (required)
- `-f, --file`: Excel file to transform (required)
- `-t, --token`: Authentication token for Solar-Planit (required)
- `--url`: Solar-Planit URL (default: http://localhost:8080)
- `--env`: MMS Environment (dev/staging, default: staging)
- `--batch-mode`: Disable spinner (useful for automated scripts)
- `-h, --help`: Show help message

**Environment Variables**:

| Variable            | Description                                                        | Default Value         | Required |
|---------------------|--------------------------------------------------------------------|-----------------------|----------|
| MMS_USERNAME        | Username for authentication against the MMS                        | admin                 | No       |
| MMS_PASSWORD        | Password for authentication against the MMS                        | -                     | Yes      |
| EXCEL_FILE          | Path to Excel file with reference data to import into Solar-Planit | -                     | Yes      |
| SP_IMPORT_API_TOKEN | Authentication token for Solar-Planit                              | -                     | Yes      |
| SOLAR_PLANIT_URL    | URL for Solar-Planit                                               | http://localhost:8080 | No       |
| ENVIRONMENT         | MMS Environment (dev/staging)                                      | staging               | No       |
| BATCH_MODE          | Disable spinner (useful for automated scripts)                     | false                 | No       |

**Dependencies**:

- Bash shell environment
- Standard Unix commands (ps, printf, echo, sleep, kill, test, source)
- Other scripts:
    - transform-excel.sh
    - portfolio-mms-import.sh
- Environment files:
    - .env in parent directory (optional)
    - .env in bin directory (optional)

**Use Case**: When you need to import portfolio data from an Excel file into the Solar-Planit system. This script
combines the transformation and import steps into a single operation.

## portfolio-mms-import.sh

**Purpose**: Imports portfolio data into Solar-Planit.

**Usage**:

```bash
./portfolio-mms-import.sh [options] -u URL -t API_TOKEN
```

**Options**:

- `-u, --url`: Solar-Planit URL (default: http://localhost:8080)
- `-t, --token`: Authentication token for Solar-Planit (required)
- `-h, --help`: Show help message

**Environment Variables**:
| Variable | Description | Default Value | Required |
|----------|-------------|---------------|----------|
| SP_IMPORT_API_TOKEN | Authentication token for Solar-Planit | - | Yes |
| SOLAR_PLANIT_URL | URL for Solar-Planit | http://localhost:8080 | No |

**Dependencies**:

- Bash shell environment
- Standard Unix commands (test, echo, source)
- curl: For making HTTP requests
- Environment files:
    - .env in parent directory (optional)
    - .env in bin directory (optional)
- Network services:
    - Solar-Planit API (default: http://localhost:8080)
- Input:
    - Expects JSON data via stdin

**Use Case**: When you need to import portfolio data into Solar-Planit. This script is typically used as part of the
excel-to-sp.sh pipeline but can be used independently if you already have properly formatted JSON data.

## transform-excel.sh

**Purpose**: Transforms an Excel file into JSON format suitable for importing into Solar-Planit.

**Usage**:

```bash
./transform-excel.sh [options] -p password -f excel_file
```

**Options**:

- `-u, --username`: Username for authentication (default: admin)
- `-p, --password`: Password for authentication (required)
- `-f, --file`: Excel file to transform (required)
- `--env`: Environment (dev/staging, default: dev)
- `-h, --help`: Show help message

**Environment Variables**:

| Variable     | Description                     | Default Value | Required |
|--------------|---------------------------------|---------------|----------|
| MMS_USERNAME | Username for authentication     | admin         | No       |
| MMS_PASSWORD | Password for authentication     | -             | Yes      |
| EXCEL_FILE   | Path to Excel file to transform | -             | Yes      |
| ENVIRONMENT  | MMS Environment (dev/staging)   | dev           | No       |

**Dependencies**:

- Bash shell environment
- Standard Unix commands (test, echo, source)
- curl: For making HTTP requests
- jq: For parsing JSON responses
- Environment files:
    - .env in parent directory (optional)
    - .env in bin directory (optional)
- Network services:
    - For staging environment:
        - https://mms-staging.squadc.com/mmsapi/v1/auth/login
        - https://mms-staging.squadc.com/mmsapi/v1/development/referencedata/transform
    - For dev environment:
        - http://localhost:8080/api/v2/auth/login
        - http://localhost:3333/development/referencedata/transform

**Use Case**: When you need to convert Excel data into a format that can be imported into Solar-Planit. This script is
typically used as part of the excel-to-sp.sh pipeline but can be used independently if you only need the transformed
data.
