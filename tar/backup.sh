#!/bin/bash

set -u
set -e
set -x

REPO=$1
HOSTNAME=$(hostname)
INCLUDE_FILE="../${HOSTNAME}-include"
EXCLUDE_FILE="../${HOSTNAME}-exclude"

if [ -z ${REPO} ]; then
  echo "No REPO specified"
  exit 1
fi

if [ ! -d ${REPO} ]; then
  echo "REPO is not a directory: ${REPO}"
  exit 1
fi

FILENAME="2017-11-26-${HOSTNAME}.tar.xz"
FILEPATH="${REPO}/${FILENAME}"

tar --create --verbose --file=${FILEPATH} --exclude-from=${EXCLUDE_FILE} --files-from=${INCLUDE_FILE}
