#!/bin/bash

set -u
set -e
set -x

REPO=$1
HOSTNAME=$(hostname)
COMMON_ARGS=(
  "-r ${REPO}"
  "--password-file ./${HOSTNAME}-password"
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
  ~/bin/restic init ${COMMON_ARGS[*]}
fi

~/bin/restic backup ${COMMON_ARGS[*]} --files-from ./${HOSTNAME}-include --exclude ./${HOSTNAME}-exclude
~/bin/restic check ${COMMON_ARGS[*]}

# Prune and check again, because we are paranoid
~/bin/restic forget ${COMMON_ARGS[*]} --keep-daily 90 --prune
~/bin/restic check ${COMMON_ARGS[*]}