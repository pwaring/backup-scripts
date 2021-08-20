#!/bin/bash

set -u
set -e
set -x
set -o pipefail

BASE_REPO=$1
CURRENT_DIR=$(dirname "${0}")
HOSTNAME=$(hostname)
INCLUDE_FILE="${CURRENT_DIR}/${HOSTNAME}-include"
EXCLUDE_FILE="${CURRENT_DIR}/${HOSTNAME}-exclude"

# Check that all include and exclude directories exist
while read -r line; do
  if [[ ! -d "${line}" && ! -f "${line}" ]]; then
    echo "${line} does not exist in ${INCLUDE_FILE}"
    exit 1
  fi
done < "${INCLUDE_FILE}"

while read -r line; do
  if [[ ! -d "${line}" && ! -f "${line}" ]]; then
    echo "${line} does not exist in ${EXCLUDE_FILE}"
    exit 1
  fi
done < "${EXCLUDE_FILE}"

if [ -z "${BASE_REPO}" ]; then
  echo "No REPO specified"
  exit 1
fi

if [ ! -d "${BASE_REPO}" ]; then
  echo "BASE_REPO is not a directory: ${BASE_REPO}"
  exit 1
fi

BORG_REPO="${BASE_REPO}/borg/"
RESTIC_REPO="${BASE_REPO}/restic/"
TAR_REPO="${BASE_REPO}/tar/"

if [ -e "${CURRENT_DIR}"/pre-backup.sh ]; then
  # Only run pre-backups if this has not been done for more than 4 hours, as this is an expensive operation
  # This is useful when we are running the all.sh backup script multiple times in quick succession, where
  # the pre-backup information is unlikely to have changed
  PB_RUN=0
  PB_RUN_FILE="${CURRENT_DIR}/pre-backup-run"

  if [ ! -f "${PB_RUN_FILE}" ]; then
    PB_RUN=1
  else
    # Create a temporary file as of 4 hours ago, then see if the pre-backup run file is older
    # This is a simple way of checking if the pre-backup run file is older than 4 hours
    PB_RUN_TMP_FILE=$(mktemp)
    touch -d"-4 hour" "${PB_RUN_TMP_FILE}"

    if [ "${PB_RUN_FILE}" -ot "${PB_RUN_TMP_FILE}" ]; then
      PB_RUN=1
    fi
  fi

  if [ $PB_RUN -eq 1 ]; then
    /bin/bash "${CURRENT_DIR}"/pre-backup.sh
    touch "${PB_RUN_FILE}"
  fi
fi

/bin/bash "${CURRENT_DIR}"/borg.sh "${BORG_REPO}"
/bin/bash "${CURRENT_DIR}"/restic.sh "${RESTIC_REPO}"
/bin/bash "${CURRENT_DIR}"/tar.sh "${TAR_REPO}"
