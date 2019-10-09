#!/bin/bash

set -u
set -e
set -x

REPO=$1
CURRENT_DIR=$(dirname $0)

# Borg requires that archive names are unique and you have to create a new
# archive each time, so we use the hostname and the current date/time
HOSTNAME=$(hostname)
CURRENT_DATE=$(date +'%Y-%m-%d-%H-%M-%S')
ARCHIVE_NAME="${HOSTNAME}-${CURRENT_DATE}"
REPO_ARCHIVE="${REPO}::${ARCHIVE_NAME}"
INCLUDE_DIRS=$(cat ${CURRENT_DIR}/../${HOSTNAME}-include)
EXCLUDE_FILE="${CURRENT_DIR}/../${HOSTNAME}-exclude"

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
  borg init --encryption=none "${REPO}"
fi

# Backup everything and check it
borg create -v --progress --stats "${REPO_ARCHIVE}" ${INCLUDE_DIRS} --exclude-from "${EXCLUDE_FILE}"
borg check --progress "${REPO}"

# Prune and then check again, because we're paranoid
borg prune -v --stats -d 90 "${REPO}"
borg check --progress "${REPO}"
