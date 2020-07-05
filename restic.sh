#!/bin/bash

set -u
set -e
set -x
set -o pipefail

REPO=$1
CURRENT_DIR=$(dirname "$0")
HOSTNAME=$(hostname)
INCLUDE_FILE="${CURRENT_DIR}/${HOSTNAME}-include"
EXCLUDE_FILE="${CURRENT_DIR}/${HOSTNAME}-exclude"
PASSWORD_FILE="${CURRENT_DIR}/${HOSTNAME}-password"

if [ -z "${REPO}" ]; then
  echo "No REPO specified"
  exit 1
fi

if [ ! -d "${REPO}" ]; then
  echo "REPO is not a directory: ${REPO}"
  exit 1
fi

# Initialise repository if it does not already exist
if [ ! -f "${REPO}/config" ]; then
  restic init -r "${REPO}" --password-file "${PASSWORD_FILE}"
fi

# Cleanup any old cache entries
restic cache --cleanup

restic backup -r "${REPO}" --password-file "${PASSWORD_FILE}" --files-from "${INCLUDE_FILE}" --exclude-file "${EXCLUDE_FILE}"
restic check -r "${REPO}" --password-file "${PASSWORD_FILE}"

# Prune anything more than 90 days
restic forget -r "${REPO}" --password-file "${PASSWORD_FILE}" --keep-daily 90 --prune
