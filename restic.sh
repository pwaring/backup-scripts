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

# Check that all include and exclude directories exist, otherwise
# restic will bail out later
while read line; do
  if [[ ! -d "${line}" && ! -f "${line}" ]]; then
    echo "${line} does not exist in ${INCLUDE_FILE}"
    exit 1
  fi
done < ${INCLUDE_FILE}

while read line; do
  if [[ ! -d "${line}" && ! -f "${line}" ]]; then
    echo "${line} does not exist in ${EXCLUDE_FILE}"
    exit 1
  fi
done < ${EXCLUDE_FILE}

if [ -z "${REPO}" ]; then
  echo "No REPO specified"
  exit 1
fi

if [ ! -d "${REPO}" ]; then
  echo "REPO is not a directory: ${REPO}"
  exit 1
fi

if [ ! -f "${REPO}/config" ]; then
  echo "REPO is not a repository: ${REPO}"
  exit 1
fi

# Cleanup any old cache entries
restic cache --cleanup

restic backup -r "${REPO}" --password-file "${PASSWORD_FILE}" --files-from "${INCLUDE_FILE}" --exclude-file "${EXCLUDE_FILE}"

# Prune anything more than 90 days
restic forget -r "${REPO}" --password-file "${PASSWORD_FILE}" --keep-within 90d --prune --verbose
restic check -r "${REPO}" --password-file "${PASSWORD_FILE}"
