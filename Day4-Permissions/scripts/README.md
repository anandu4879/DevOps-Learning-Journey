Here you go:

day04-file-permissions/README.md

markdown
# Day 04 — File Permissions, Users, Groups & Special Permissions

Probably the most important day so far. Permissions are everywhere in Linux
and getting them wrong either locks you out of your own files or opens up
security holes. Spent a lot of time on this one and it was worth it.

---

## The Permission String

Every file has a permission string. You see it when you run `ls -l`:

```
-rwxr-xr-x  1  anand  staff  4096  Jun 4  script.sh
↑ ↑↑↑ ↑↑↑ ↑↑↑
│  │    │   └── Others  (everyone else)
│  │    └────── Group   (people in the same group)
│  └─────────── Owner   (the file's owner)
└────────────── File type (- file, d directory, l symlink)
```

Each group gets three characters — r (read), w (write), x (execute).
A `-` means that permission is off.

**What permissions mean on folders:**
```
r   can list contents with ls
w   can create or delete files inside
x   can enter the folder with cd
```

Without `x` on a folder you can't `cd` into it — that's why folders are
usually 755 and not 644.

---

## Octal Notation

Each permission has a value:
```
r = 4
w = 2
x = 1
- = 0
```

Add them up per group to get the number:
```
rwx = 4+2+1 = 7
rw- = 4+2+0 = 6
r-x = 4+0+1 = 5
r-- = 4+0+0 = 4
--- = 0+0+0 = 0
```

So `chmod 755` means owner=7(rwx), group=5(r-x), others=5(r-x).

**Most used combinations:**

| Octal | String     | Use for                        |
|-------|------------|--------------------------------|
| 777   | rwxrwxrwx  | never use this                 |
| 755   | rwxr-xr-x  | scripts, folders               |
| 644   | rw-r--r--  | normal files                   |
| 600   | rw-------  | private files, SSH keys, .env  |
| 700   | rwx------  | private scripts                |
| 400   | r--------  | sensitive read-only config     |

---

## `chmod` — Changing Permissions

```bash
# octal method
chmod 755 script.sh
chmod 644 notes.txt
chmod 600 secret.txt
chmod -R 755 folder/        # recursive — applies to everything inside

# symbolic method
chmod u+x script.sh         # add execute for owner
chmod g-w file.txt          # remove write from group
chmod o+r file.txt          # add read for others
chmod a+x script.sh         # add execute for everyone
chmod u+x,g-w file.txt      # multiple changes at once
chmod u=rwx,g=rx,o=r file   # set exact permissions

# who the letters mean
# u = user/owner
# g = group
# o = others
# a = all
# + adds, - removes, = sets exactly
```

---

## `chown` and `chgrp` — Changing Ownership

```bash
chown anand file.txt            # change owner
chown anand:staff file.txt      # change owner and group
chown :staff file.txt           # change only group
chown -R anand:staff folder/    # recursive

chgrp staff file.txt            # change group only
chgrp -R staff folder/          # recursive

# check current owner
ls -l file.txt
```

---

## Users & Groups

### Key files
```bash
cat /etc/passwd     # all users — format: user:x:UID:GID:desc:home:shell
cat /etc/shadow     # hashed passwords — needs root to read
cat /etc/group      # all groups — format: group:x:GID:members
```

### Useful commands
```bash
whoami              # your username
id                  # your UID, GID and all groups
groups              # groups you belong to
id username         # info about another user
getent group devteam    # see who's in a group
```

### Managing users (on Linux / KodeKloud)
```bash
useradd -m username                     # create user with home folder
useradd -m -s /bin/bash username        # with bash shell
useradd -m -G sudo,staff username       # add to groups on creation
passwd username                         # set password

usermod -aG developers anand            # add to group — always use -a
usermod -s /bin/zsh username            # change shell
usermod -L username                     # lock account
usermod -U username                     # unlock account

userdel username                        # delete user, keep home
userdel -r username                     # delete user and home folder

su username                             # switch to user
su - username                           # switch with their environment
sudo -l                                 # what sudo commands can I run
```

### Managing groups
```bash
groupadd developers             # create group
gpasswd -a anand developers     # add user to group
gpasswd -d anand developers     # remove user from group
groupdel developers             # delete group
```

### Reading /etc/passwd
```
root:x:0:0:root:/root:/bin/bash
  ↑  ↑ ↑ ↑  ↑     ↑        ↑
  │  │ │ │  │     │        └── shell
  │  │ │ │  │     └─────────── home directory
  │  │ │ │  └───────────────── description
  │  │ │ └──────────────────── GID
  │  │ └────────────────────── UID
  │  └──────────────────────── password (x means in /etc/shadow)
  └─────────────────────────── username

# system users have UID below 1000
# regular users start at 1000
awk -F: '$3 >= 1000 {print $1, $3}' /etc/passwd
```

---

## Special Permissions

These sit in front of the regular three digits when using octal.
SUID=4, SGID=2, Sticky=1 — same add-up logic as rwx.

### SUID — Set User ID (4)

Makes a file run as its owner instead of the person running it.

```bash
# classic example — passwd runs as root so it can edit /etc/shadow
ls -l /usr/bin/passwd
# -rwsr-xr-x  root
#     ↑ s in owner execute position = SUID

chmod u+s file
chmod 4755 file         # 4 in front

# find all SUID files on system
find / -perm -4000 -type f 2>/dev/null
```

⚠️ SUID is ignored on shell scripts — only works on compiled binaries.

---

### SGID — Set Group ID (2)

On files — runs as the file's group.
On folders — new files created inside inherit the folder's group.

```bash
# s in group execute position = SGID
ls -l /usr/bin/write
# -rwxr-sr-x  tty
#        ↑

# on a shared folder — most common use
mkdir teamfolder
chown :developers teamfolder
chmod g+s teamfolder
chmod 2755 teamfolder
# any file created inside now belongs to developers group automatically

# find all SGID files
find / -perm -2000 -type f 2>/dev/null
```

---

### Sticky Bit (1)

Without it — anyone with write on a folder can delete any file in it.
With it — you can only delete files you own.

```bash
# /tmp is the classic example
ls -ld /tmp
# drwxrwxrwt
#          ↑ t = sticky bit

chmod +t folder/
chmod 1777 folder/

# lowercase t = sticky + execute set
# uppercase T = sticky set but execute is NOT set
```

---

## ACLs — Access Control Lists

Regular permissions only allow one owner and one group. ACLs let you give
specific permissions to specific users or groups on top of that.

```bash
# a + at the end of permissions means an ACL is set
ls -l file.txt
# -rw-r--r--+

# view ACLs
getfacl file.txt

# give a specific user read/write
setfacl -m u:bob:rw file.txt

# give a specific group read access
setfacl -m g:developers:r file.txt

# set default ACL on folder — new files inherit it
setfacl -d -m u:bob:rw sharedfolder/

# remove one ACL entry
setfacl -x u:bob file.txt

# remove ALL ACLs
setfacl -b file.txt

# recursive
setfacl -R -m u:bob:rw folder/
```

### The ACL Mask
```bash
# the mask limits what ACL entries can actually do
# even if bob has rwx, mask r-- means bob only gets r--
# owner and others are not affected by the mask

setfacl -m m::rwx file.txt      # set mask to allow full permissions
```

### Real world example
```bash
# give contractor sarah read access to /project
# without adding her to the developers group

setfacl -m u:sarah:r-x /project
getfacl /project
# user::rwx
# user:sarah:r-x
# group::rwx
# mask::rwx
# other::---
```

---

## Real World Scenarios

```bash
# SSH private key — must be 600 or SSH refuses to use it
chmod 600 ~/.ssh/id_rsa

# shell script
chmod 755 myscript.sh

# config file readable by others but not writable
chmod 644 config.txt

# .env file — only you should ever read it
chmod 600 .env

# web server files
chmod -R 755 /var/www/html/

# shared temp folder — anyone can add, no one deletes others' files
chmod 1777 /tmp/shared/
```

---

## Viewing Permissions in Octal

```bash
stat -f "%OLp %N" file.txt      # Mac
stat -c "%a %n" file.txt        # Linux
```

---

## Scripts I Wrote Today

### `permaudit.sh`
Scans a folder and flags world-writable files, 777 permissions,
and .sh files that aren't executable. Prints a summary at the end.

### `setupproject.sh`
Full project setup script — creates users, groups, folder structure,
sets SGID and sticky bit on the right folders, adds ACL entries for
an auditor user, prints a full summary at the end.

---

## Things That Tripped Me Up

- `usermod -aG` — the `-a` means append. If you forget `-a` and just
  use `-G` it replaces ALL your groups with just that one. Lost sudo
  access that way on KodeKloud once.
- SUID on shell scripts does nothing — Linux ignores it for security.
  Only works on compiled binaries.
- Capital `T` vs lowercase `t` on sticky bit — lowercase means execute
  is also set which is what you usually want. Capital T means sticky
  is there but execute is off.
- ACL mask silently limits permissions — always check with `getfacl`
  after setting ACLs to make sure the mask isn't cutting them down.

---

## Mac vs Linux Differences

| Task | Linux | Mac |
|------|-------|-----|
| Get octal permissions | `stat -c "%a"` | `stat -f "%OLp"` |
| ACL commands | `setfacl` / `getfacl` | `chmod +a` / `ls -le` |
| Create users | `useradd` | `dscl` (different entirely) |
| sudoers file | `/etc/sudoers` | `/etc/sudoers` (same) |

---