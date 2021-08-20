#!/bin/bash

set -u
set -e
set -x
set -o pipefail

REPO=$1
CURRENT_DIR=$(dirname $0)

# Borg requires that archive names are unique and you have to create a new
# archive each time, so we use the hostname and the current date/time
HOSTNAME=$(hostname)
CURRENT_DATE=$(date +'%Y-%m-%d-%H-%M-%S')
ARCHIVE_NAME="${HOSTNAME}-${CURRENT_DATE}"
REPO_ARCHIVE="${REPO}::${ARCHIVE_NAME}"
INCLUDE_FILE="${CURRENT_DIR}/${HOSTNAME}-include"
INCLUDE_DIRS=$(cat ${INCLUDE_FILE})
EXCLUDE_FILE="${CURRENT_DIR}/${HOSTNAME}-exclude"

# Check that all include and exclude directories exist, otherwise
# borg will bail out later
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

# Backup everything
borg create -v --progress --stats "${REPO_ARCHIVE}" ${INCLUDE_DIRS} --exclude-from "${EXCLUDE_FILE}"

# Only run borg check if this has not been done for more than 7 days, as this is an expensive operation
BORG_CHECK=0
BORG_CHECK_FILE="${REPO}/../borg-check"

if [ ! -f "${BORG_CHECK_FILE}" ]; then
  BORG_CHECK=1
else
  # Create a temporary file as of 7 days ago, then see if the borg check file is older
  # This is a simple way of checking if the borg check file is older than 7 days
  BORG_CHECK_TMP_FILE=$(mktemp)
  touch -d"-7 day" "${BORG_CHECK_TMP_FILE}"

  if [ "${BORG_CHECK_FILE}" -ot "${BORG_CHECK_TMP_FILE}" ]; then
    BORG_CHECK=1
  fi
fi

if [ $BORG_CHECK -eq 1 ]; then
  borg check --progress "${REPO}"
  touch ${BORG_CHECK_FILE}
fi

# Prune anything other than 90 days of backups 
borg prune -v --stats --list --keep-within 90d "${REPO}"
