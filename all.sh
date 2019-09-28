#!/bin/bash

set -u
set -e
set -x

BASE_REPO=$1
CURRENT_DIR=$(dirname $0)

BORG_REPO="${BASE_REPO}/borg/"
RESTIC_REPO="${BASE_REPO}/restic/"
TAR_REPO="${BASE_REPO}/tar/"

/bin/bash ${CURRENT_DIR}/borg/backup.sh ${BORG_REPO}
/bin/bash ${CURRENT_DIR}/restic/backup.sh ${RESTIC_REPO}
/bin/bash ${CURRENT_DIR}/tar/backup.sh ${TAR_REPO}
