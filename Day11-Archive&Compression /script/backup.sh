#!/bin/bash

# Takes one argument — folder to backup
FOLDER=$1
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Validate input
[[ -z "$FOLDER" ]] && { echo "Usage: $0 <folder>"; exit 1; }
[[ ! -d "$FOLDER" ]] && { echo "Folder not found: $FOLDER"; exit 1; }

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup using tar
echo "Backing up $FOLDER..."
tar -czf "$BACKUP_DIR/backup_${TIMESTAMP}.tar.gz" "$FOLDER"

# Verify backup
if tar -tzf "$BACKUP_DIR/backup_${TIMESTAMP}.tar.gz" > /dev/null 2>&1; then
    echo "✓ Backup successful"
    ls -lh "$BACKUP_DIR/backup_${TIMESTAMP}.tar.gz"
else
    echo "✗ Backup failed"
    exit 1
fi

# Cleanup old backups (keep only 7 days)
echo "Cleaning up old backups..."
find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete

echo "Done"