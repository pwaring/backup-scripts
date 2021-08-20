#!/bin/bash

set -u
set -e
set -x
set -o pipefail

REPO=$1
CURRENT_DIR=$(dirname $0)
HOSTNAME=$(hostname)
INCLUDE_FILE="${CURRENT_DIR}/${HOSTNAME}-include"
EXCLUDE_FILE="${CURRENT_DIR}/${HOSTNAME}-exclude"
TODAY_DATE=$(date +'%Y-%m-%d')

# Check that all include and exclude directories exist, otherwise
# tar will bail out later
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

FILENAME="${TODAY_DATE}-${HOSTNAME}.tar.xz"
FILEPATH="${REPO}/${FILENAME}"

tar --create --verbose --file="${FILEPATH}" --exclude-from=${EXCLUDE_FILE} --files-from=${INCLUDE_FILE}

# Delete all but 7 most recent backups

# Braces around command convert the list returned into an array
# find returns in ascending order so use sort -r to reverse
BACKUPS=($(find "${REPO}" -name *-${HOSTNAME}.tar.xz | sort -r))
echo ${BACKUPS[*]}
KEEP_BACKUPS=7
BACKUP_COUNT=${#BACKUPS[@]}

for (( i=$(($KEEP_BACKUPS)); i<$(($BACKUP_COUNT)); i++ ))
do
  rm "${BACKUPS[$i]}"
done
