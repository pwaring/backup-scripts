# Backup scripts

Wrapper scripts for various backup systems (currently: borg, restic and tar).

## tar

The `tar` command is found on most Unix systems and supports compression.

The following limitations apply to the `tar` backup script:

 * Multiple backups on the same day will overwrite each other, i.e. only the last will be kept.
 * 7 backups are kept, all others are deleted (this is configurable).
 * Backup retention is based on the number of backups, not the number of days.

## Pre-backups

The `all.sh` wrapper script will check for a file called `pre-backup.sh` and
execute it if it exists. This is useful if you wish to perform some tasks
before starting a backup, such as exporting MySQL databases.

## Limitations

All the backup scripts suffer from the following limitations:

 * Backups may fail if the repository path includes spaces.
