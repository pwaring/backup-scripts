#!/bin/bash

set -u
set -e
set -x

REPO=$1
HOSTNAME=$(hostname)
INCLUDE_FILE="../${HOSTNAME}-include"
EXCLUDE_FILE="../${HOSTNAME}-exclude"
TODAY_DATE=$(date +'%Y-%m-%d')

if [ -z ${REPO} ]; then
  echo "No REPO specified"
  exit 1
fi

if [ ! -d ${REPO} ]; then
  echo "REPO is not a directory: ${REPO}"
  exit 1
fi

FILENAME="${TODAY_DATE}-${HOSTNAME}.tar.xz"
FILEPATH="${REPO}/${FILENAME}"

tar --create --verbose --file=${FILEPATH} --exclude-from=${EXCLUDE_FILE} --files-from=${INCLUDE_FILE}

# Delete all but 5 most recent backups

# Braces around command convert the list returned into an array
# find returns in ascending order so use sort -r to reverse
BACKUPS=($(find ${REPO} -name '*.tar.xz' | sort -r))
echo ${BACKUPS[*]}
KEEP_BACKUPS=7
BACKUP_COUNT=${#BACKUPS[@]}

for (( i=$(($KEEP_BACKUPS)); i<$(($BACKUP_COUNT)); i++ ))
do
  echo ${BACKUPS[$i]}
done
