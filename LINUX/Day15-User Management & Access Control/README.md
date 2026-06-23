# Day 15 — User Management & Access Control

Today was about understanding the invisible system that controls who can
do what on a Linux server. Three files, one concept: controlling access.

---

## The Three Files

### `/etc/passwd` — The Phone Book
Lists all users on the system. Everyone can read it.

```bash
cat /etc/passwd
# anand:x:1000:1000:Anandu Pradeep:/home/anand:/bin/zsh
#  │    │ │    │    │                │              │
#  │    │ │    │    │                │              └─ shell
#  │    │ │    │    │                └─ home directory
#  │    │ │    │    └─ full name
#  │    │ │    └─ GID (group ID)
#  │    │ └─ UID (user ID — unique number)
#  │    └─ x = password is elsewhere (security)
#  └─ username
```

### `/etc/shadow` — The Password Vault
Actual encrypted passwords. Only root can read. Much safer.

```bash
sudo cat /etc/shadow
# root:$6$abcd...:18989:0:99999:7:::
#     └─ encrypted password (unreadable without the key)
```

### `/etc/group` — Teams/Groups
Users can be in groups. Makes it easier to give permissions to multiple
people at once instead of one by one.

```bash
cat /etc/group
# sudo:x:27:anand,bob
#      └─ anand and bob are in the sudo group
```

---

## Users — Creating and Managing

```bash
# create user with home directory and bash shell
sudo useradd -m -s /bin/bash username

# set password
sudo passwd username

# delete user (keep home folder)
sudo userdel username

# delete user (remove everything)
sudo userdel -r username

# modify shell
sudo usermod -s /bin/zsh username

# add to group (important: -aG means append, don't remove from other groups)
sudo usermod -aG groupname username

# see user info
id username
```

---

## Groups — Teams of Users

```bash
# create group
sudo groupadd developers

# add user to group
sudo usermod -aG developers alice

# remove user from group
sudo deluser alice developers

# delete group
sudo groupdel developers

# see group members
grep developers /etc/group
```

### Why Groups Matter

Instead of giving permission to each person individually:
```bash
# bad — give permission to 10 people one by one
chmod u=rwx,g=,o= file1
chmod u=rwx,g=,o= file2
# repeat 10 times...

# good — create a group, add people, give permission to group
sudo groupadd developers
sudo usermod -aG developers alice
sudo usermod -aG developers bob
sudo chown -R :developers folder/
sudo chmod -R g+rwx folder/

# now all developers have access automatically
```

---

## Permissions + Ownership

```bash
# change owner
sudo chown newuser file.txt

# change group
sudo chown :newgroup file.txt

# change both
sudo chown newuser:newgroup file.txt

# recursively (folders + all files inside)
sudo chown -R newuser:newgroup folder/

# Example: give developers group access
sudo chown -R :developers /var/devproject/
sudo chmod -R g+rwx /var/devproject/

# now all developers can read/write in that folder
```

---

## sudo — Temporary Superpowers

Regular users can't install software, restart services, or modify system files.
`sudo` gives them temporary root power for one command.

```bash
# user tries to install (fails)
apt install curl
# permission denied

# with sudo
sudo apt install curl
# works! (if user is in sudoers list)

# give user sudo access
sudo usermod -aG sudo username

# now they can run sudo commands
# (system asks for their password each time)
```

### The sudoers File

Controls who can use sudo. Edit carefully — wrong syntax breaks everything.

```bash
# edit sudoers (safe editor — checks syntax)
sudo visudo

# common lines:
root ALL=(ALL:ALL) ALL        # root can do anything
anand ALL=(ALL:ALL) ALL       # anand can do anything with sudo
%sudo ALL=(ALL:ALL) ALL       # anyone in sudo group can use sudo
```

Reading it:
```
anand ALL=(ALL:ALL) ALL
│     │   │       │ │
│     │   │       │ └─ can run any command
│     │   │       └─ as any group
│     │   └─ as any user
│     └─ on any host
└─ username
```

---

## Real DevOps Scenarios

### Onboard a New Developer

```bash
#!/bin/bash
USERNAME=$1

# create account
sudo useradd -m -s /bin/bash "$USERNAME"
sudo passwd "$USERNAME"

# add to groups
sudo groupadd developers 2>/dev/null || true
sudo usermod -aG developers "$USERNAME"
sudo usermod -aG sudo "$USERNAME"    # can use sudo

# give access to dev folder
sudo mkdir -p /var/devproject
sudo chown -R "$USERNAME:developers" /var/devproject
sudo chmod -R u=rwx,g=rwx,o= /var/devproject

echo "$USERNAME is ready to go"
```

### Secure a Database Server

```bash
# database should run as its own user, not root
sudo useradd -m -s /bin/nologin postgres

# give database user access to its data
sudo chown -R postgres:postgres /var/lib/postgresql/
sudo chmod -R u=rwx,g=,o= /var/lib/postgresql/

# now only postgres can access its data
# attacker can't read database files even if they get into the server
```

### Team Shared Folder

```bash
# create group
sudo groupadd team_alpha

# add team members
sudo usermod -aG team_alpha alice
sudo usermod -aG team_alpha bob
sudo usermod -aG team_alpha charlie

# create shared folder
sudo mkdir -p /var/team_alpha_project
sudo chown -R :team_alpha /var/team_alpha_project
sudo chmod -R g+rwx /var/team_alpha_project

# now all three can read/write
# no one else can see it
```

---

## Challenges Done

### Challenge 1 — Explore Your Users
Looked at /etc/passwd, found my user, checked UID and groups.

### Challenge 2 — Create Test Users
Created users, set passwords, added to groups, deleted them.

### Challenge 3 — Create Development Team
Created group, added users, created shared folder with proper permissions.

### Challenge 4 — Understand sudoers
Checked who has sudo access, verified the sudoers file is valid.

### Challenge 5 — Permissions with Users
Changed ownership and permissions based on user and group.

---

## Scripts Written

### `usertools.sh`
Full user management tool with create, delete, addgroup, list, info commands.
Safe, with error checking. Real DevOps tool — not just a learning script.

---

## Things That Clicked

- `/etc/passwd` is readable by everyone, `/etc/shadow` only by root
- UID is a number, username is just a label for that number
- Groups solve the "give 10 people access without 10 separate commands" problem
- `sudo` doesn't run as root by default — it runs as your user, just with
  elevated permissions. That's why you enter YOUR password, not root's.
- `:groupname` in chown means "group" — without the colon it means "user"
- `sudo usermod -aG` is critical: without `-a` it removes from other groups
- Permissions on `/etc/shadow` are `------` (nobody can read except root)
  for a reason — encrypted passwords still shouldn't leak

---

## The Real Understanding

User management isn't about memorizing commands. It's about understanding:

1. **Identity** — who are you? (/etc/passwd)
2. **Secrets** — how do we know it's really you? (/etc/shadow)
3. **Teams** — which group do you belong to? (/etc/group)
4. **Access** — what are you allowed to do? (permissions + groups)
5. **Privilege** — can you do admin stuff? (sudo)

Every Linux security decision traces back to these concepts.

