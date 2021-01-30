# Backup scripts

Wrapper scripts for various backup systems (currently: borg, restic and tar).

## Configuration

Place the password for restic backups in: $(hostname)-password

Place directories you want to backup in: $(hostname)-include

Place directories you do not want to backup in: $(hostname)-exclude

Both include and exclude files must end in a newline, otherwise the last directory will not be processed.

## tar

The `tar` command is found on most Unix systems and supports compression.

The following limitations apply to the `tar` backup script:

 * Multiple backups on the same day will overwrite each other, i.e. only the last will be kept.
 * 7 backups are kept, all others are deleted (this is configurable).
 * Backup retention is based on the number of backups, not the number of days.

## restic

[restic](https://restic.net/) is an open source backup system written in Go. It is under active development and supports a wide range of backup sources. It supports deduplication and encryption.

The latest version of restic is available as a Snap, or it can be built easily from source if you have a recent Go compiler.

## Borg

[Borg](https://www.borgbackup.org/) has been around for a long time (and is a fork of a previous project, Attic). It supports deduplication and encryption.



## Pre-backups

The `all.sh` wrapper script will check for a file called `pre-backup.sh` and
execute it if it exists. This is useful if you wish to perform some tasks
before starting a backup, such as exporting MySQL databases.

## Limitations

All the backup scripts suffer from the following limitations:

 * Backups may fail if the repository path includes spaces.
