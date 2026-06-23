# KodeKloud Git Labs - Notes & Solutions

## 1. Install Git and Create a Bare Repository

### Task

The Nautilus development team requested a Git repository on the Storage Server.

Requirements:

* Install Git using yum.
* Create a bare repository named `/opt/media.git`.

### Commands

```bash
sudo su -
yum install -y git
git --version

git init --bare /opt/media.git
```

### Verification

```bash
ls -la /opt/media.git
```

### Concept

A bare repository contains only Git metadata and no working directory.

Example:

```text
media.git/
├── HEAD
├── config
├── hooks/
├── objects/
└── refs/
```

Used as a central remote repository for developers.

---

## 2. Clone Existing Repository

### Task

Clone:

```text
/opt/beta.git
```

into:

```text
/usr/src/kodekloudrepos
```

using the `natasha` user.

### Commands

```bash
su - natasha

git clone /opt/beta.git /usr/src/kodekloudrepos
```

### Verification

```bash
cd /usr/src/kodekloudrepos

git remote -v
git status
```

---

## 3. Fork Repository in Gitea

### Task

Login to Gitea:

```text
Username: jon
Password: Jon_pass123
```

Fork:

```text
sarah/story-blog
```

to:

```text
jon/story-blog
```

### Steps

1. Open Gitea UI.
2. Login as jon.
3. Open repository `sarah/story-blog`.
4. Click Fork.
5. Select user `jon`.
6. Confirm fork.

### Verification

Repository should appear as:

```text
jon/story-blog
```

---

## 4. Add File to Git Repository and Push

### Task

Repository:

```text
/usr/src/kodekloudrepos/beta
```

Source file:

```text
/tmp/index.html
```

Copy file, commit, and push to master branch.

### Copy File from Jump Host

```bash
scp /tmp/index.html natasha@ststor01:/tmp/
```

### On Storage Server

```bash
ssh natasha@ststor01

cd /usr/src/kodekloudrepos/beta

cp /tmp/index.html .

git add index.html

git commit -m "Add sample index.html"

git push origin master
```

### Verification

```bash
git log --oneline -1
git status
```

---

## 5. Delete Git Branch

### Task

Delete branch:

```text
xfusioncorp_blog
```

from repository:

```text
/usr/src/kodekloudrepos/blog
```

### Check Current Branch

```bash
cd /usr/src/kodekloudrepos/blog

git branch
```

Example:

```text
master
* xfusioncorp_blog
```

### Switch Branch

```bash
git checkout master
```

or

```bash
git switch master
```

### Delete Branch

```bash
git branch -d xfusioncorp_blog
```

If not merged:

```bash
git branch -D xfusioncorp_blog
```

### Verification

```bash
git branch
```

Expected:

```text
* master
```

---

# Common Git Issues Encountered

## 1. Dubious Ownership

Error:

```text
fatal: detected dubious ownership in repository
```

Fix:

```bash
git config --global --add safe.directory /path/to/repository
```

Example:

```bash
git config --global --add safe.directory /usr/src/kodekloudrepos/beta
```

---

## 2. Permission Denied

Error:

```text
Permission denied
```

Cause:

* Repository owned by another user.
* Current user lacks write permission.

Check ownership:

```bash
ls -ld repository
ls -ld repository/.git
```

---

## 3. Cannot Delete Current Branch

Error:

```text
error: cannot delete branch 'branch_name' used by worktree
```

Cause:

* Currently checked out branch.

Fix:

```bash
git checkout master
git branch -D branch_name
```

---

## 4. Not a Git Repository

Error:

```text
fatal: not a git repository
```

Cause:

* Running Git commands outside repository.

Check current directory:

```bash
pwd
```

Move into repository:

```bash
cd /path/to/repository
```

---

# Git Commands Cheat Sheet

## Clone Repository

```bash
git clone <repo>
```

## Check Status

```bash
git status
```

## Add Files

```bash
git add file
git add .
```

## Commit

```bash
git commit -m "message"
```

## Push

```bash
git push origin master
```

## View Branches

```bash
git branch
```

## Create Branch

```bash
git branch branch_name
```

## Switch Branch

```bash
git checkout branch_name
```

## Delete Branch

```bash
git branch -d branch_name
git branch -D branch_name
```

## View Remote

```bash
git remote -v
```

## View Commit History

```bash
git log --oneline
```

---

# Key Concepts Learned

* Git Installation
* Bare Repository
* Local Repository
* Remote Repository
* Git Clone
* Git Add
* Git Commit
* Git Push
* Git Branch Management
* Git Forking (Gitea)
* Repository Ownership Issues
* Safe Directory Configuration
* Permission Troubleshooting
