#!/bin/bash

set -u
set -e
set -x
set -o pipefail

BASE_REPO=$1
CURRENT_DIR=$(dirname $0)

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
