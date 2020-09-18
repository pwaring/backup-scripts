#!/bin/bash

set -u
set -e
set -x
set -o pipefail

BASE_REPO=$1
CURRENT_DIR=$(dirname $0)
HOSTNAME=$(hostname)
INCLUDE_FILE="${CURRENT_DIR}/${HOSTNAME}-include"
EXCLUDE_FILE="${CURRENT_DIR}/${HOSTNAME}-exclude"

# Check that all include and exclude directories exist
while read line; do
  if [ ! -d ${line} ]; then
    echo "${line} does not exist in ${INCLUDE_FILE}"
    exit 1
  fi
done < ${INCLUDE_FILE}

while read line; do
  if [ ! -d ${line} ]; then
    echo "${line} does not exist in ${EXCLUDE_FILE}"
    exit 1
  fi
done < ${EXCLUDE_FILE}

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

if [ -e ${CURRENT_DIR}/pre-backup.sh ]; then
  /bin/bash ${CURRENT_DIR}/pre-backup.sh
fi

/bin/bash ${CURRENT_DIR}/borg.sh "${BORG_REPO}"
/bin/bash ${CURRENT_DIR}/restic.sh "${RESTIC_REPO}"
/bin/bash ${CURRENT_DIR}/tar.sh "${TAR_REPO}"
