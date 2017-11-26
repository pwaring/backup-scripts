# backup-scripts

Wrapper scripts for various backup systems

## tar

The `tar` command is found on most Unix systems and supports compression.

The following limitations apply to the `tar` backup script:

 * Multiple backups on the same day will overwrite each other, i.e. only the last will be kept.
 * 7 backups are kept, all others are deleted.
 * Backup retention is based on the number of backups, not the number of days.
