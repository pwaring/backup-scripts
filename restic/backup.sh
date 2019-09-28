#!/bin/bash

set -u
set -e
set -x

REPO=$1
CURRENT_DIR=$(dirname $0)
HOSTNAME=$(hostname)
INCLUDE_FILE="${CURRENT_DIR}/../${HOSTNAME}-include"
EXCLUDE_FILE="${CURRENT_DIR}/../${HOSTNAME}-exclude"
COMMON_ARGS=(
  "-r ${REPO}"
  "--password-file ${CURRENT_DIR}/../${HOSTNAME}-password"
)

if [ -z ${REPO} ]; then
  echo "No REPO specified"
  exit 1
fi

if [ ! -d ${REPO} ]; then
  echo "REPO is not a directory: ${REPO}"
  exit 1
fi

# Initialise repository if it does not already exist
if [ ! -f ${REPO}/config ]; then
  restic init ${COMMON_ARGS[*]}
fi

# Cleanup any old cache entries
restic cache --cleanup

restic backup ${COMMON_ARGS[*]} --files-from ${INCLUDE_FILE} --exclude-file ${EXCLUDE_FILE}
restic check ${COMMON_ARGS[*]}

# Prune and check again, because we are paranoid
restic forget ${COMMON_ARGS[*]} --keep-daily 90 --prune
restic check ${COMMON_ARGS[*]}
