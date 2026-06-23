# Day 11 — Archives & Compression

Today was about moving files around efficiently. Three core tools:
tar, gzip, and rsync. Used constantly in DevOps for backups and deployments.

---

## `tar` — Container Files

Bundles multiple files into one. Doesn't compress by default.

```bash
# create
tar -cf archive.tar file1 file2

# with compression (standard)
tar -czf archive.tar.gz folder/

# list contents
tar -tzf archive.tar.gz

# extract
tar -xzf archive.tar.gz

# extract to specific folder
tar -xzf archive.tar.gz -C /tmp/

# extract one file only
tar -xzf archive.tar.gz path/to/file.txt
```

### Flags

```
c    create
x    extract
t    list/test
f    filename follows
z    gzip compress
v    verbose
```

### Real uses

```bash
# backup with date in filename
tar -czf backup_$(date +%Y%m%d).tar.gz /var/www/

# backup to remote server (piped)
tar -czf - /var/www/ | ssh user@server "tar -xzf - -C /backups/"

# verify backup integrity
tar -tzf archive.tar.gz > /dev/null && echo "good"

# cleanup backups older than 30 days
find ~/backups -name "*.tar.gz" -mtime +30 -delete
```

---

## `gzip` — Compress Single Files

```bash
# compress a file
gzip myfile.txt         # becomes myfile.txt.gz

# decompress
gunzip myfile.txt.gz    # becomes myfile.txt

# compress but keep original
gzip -k myfile.txt      # keeps both
```

Use gzip for individual files. Use tar -z for folders.

---

## `rsync` — Copy Smart

Only copies what changed. Perfect for backups and syncing servers.

```bash
# local copy
rsync -av /source/ /dest/

# to remote server
rsync -av /local/ user@server:/remote/

# from remote
rsync -av user@server:/remote/ /local/

# with compression over network
rsync -avz /local/ user@server:/remote/

# delete files on dest if not on source
rsync -av --delete /source/ /dest/

# dry run — see what would copy without copying
rsync -avn /source/ /dest/

# exclude certain folders
rsync -av --exclude=node_modules /app/ /backup/app/
```

### Why rsync over cp

```
rsync → only copies changed files
     → can resume if interrupted
     → can compress over network
     → great for large amounts of data
     
cp    → copies everything
     → can't resume
     → good for local, small amounts
```

---

## Practical Scenarios

### Backup Before Update

```bash
tar -czf /backups/app_$(date +%Y%m%d_%H%M%S).tar.gz /var/www/app/
# ... do update ...
# if broken: tar -xzf /backups/app_*.tar.gz -C /
```

### Move Large Amount of Data

```bash
# rsync over network is faster
rsync -avz --progress /huge/ user@server:/remote/

# if interrupted, run again
# second run only copies what's missing
rsync -avz --progress /huge/ user@server:/remote/
```

### Keep Two Servers in Sync

```bash
# from server A, sync to server B
rsync -av --delete /app/ user@serverB:/app/
# now B matches A exactly
```

---

## Scripts Written

### `backup.sh`
Takes a folder as argument, creates timestamped compressed backup,
verifies it's good, cleans up backups older than 7 days.

---

## Challenges Done

### Challenge 1 — Backup and Restore
Created folder, archived it with compression, listed contents without
extracting, extracted to test folder, verified it matched original.

### Challenge 2 — Compress Old Logs
Created dummy log files, compressed them with gzip, checked compression ratio.

### Challenge 3 — rsync with --delete
Synced folder, modified files, added new files, deleted files,
and verified --delete removed them from destination too.

---

## Things That Clicked

- `tar -czf` is THE command for backups — compress and archive in one go
- `rsync --delete` is dangerous but powerful — makes destination
  an exact copy, deleting what's not on source
- `tar -xzf - | ssh` pipes archive over network — very fast for
  large backups without needing intermediate disk space
- Verification with `tar -tzf > /dev/null` before deleting original
  is non-negotiable — the one time you skip it is the time the
  backup is corrupt

---

## Mac vs Linux Differences

| Task | Linux | Mac |
|------|-------|-----|
| tar | `tar -czf` | `tar -czf` (same) |
| gzip | `gzip file` | `gzip file` (same) |
| rsync | `rsync -av` | `rsync -av` (same) |

No differences really — tar, gzip, rsync work the same everywhere.
