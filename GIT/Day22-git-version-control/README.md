# Day 22 — Git & Version Control

Today I learned Git — the tool that tracks every change to your code,
lets multiple people work safely, and lets you go back in time if needed.

Every company uses this. Every DevOps engineer lives in Git.

---

## What Is Git

Git is a **version control system**. It's a time machine for your code.

```
Without Git:
code.py v1
code.py v2
code_old.py
code_final.py
(which one works? no idea)

With Git:
all versions tracked
easy rollback
see who changed what
multiple people work safely
```

---

## The Workflow

```
Write code
    ↓
Add changes (git add)
    ↓
Commit (git commit) — save a version
    ↓
Repeat
```

```bash
echo "code" > app.py           # write
git add app.py                 # stage
git commit -m "Add app"        # save
git log                        # see history
```

---

## Branches (Safe Experimentation)

A branch is a separate copy of your code.

```
main branch (production):
├── always works
├── tested
└── people use this

feature-login branch:
├── experimental
├── work in progress
└── won't affect main
```

```bash
# create and switch to branch
git checkout -b feature-login

# work on feature
echo "login code" > login.py
git add .
git commit -m "Add login"

# switch back to main
git checkout main
# login.py is NOT in main yet!

# merge feature into main
git merge feature-login
# now login.py IS in main
```

---

## Merging (Combining Code)

Merge takes a branch and combines it with another.

```bash
# on main, merge feature
git merge feature-login

# feature code is now in main
# feature branch can be deleted
git branch -d feature-login
```

### Merge Conflicts

When Git can't automatically merge (both changed same lines):

```bash
git merge feature-database
# CONFLICT!

# open file, see markers:
<<<<<<< HEAD
main version
=======
feature version
>>>>>>> feature-database

# keep one, delete markers
git add <file>
git commit -m "Resolve conflict"
```

---

## Cherry-Pick (Take One Commit)

Cherry-pick copies a specific commit from one branch to another.

```bash
# on feature branch with commits:
# abc123 - Fix critical bug
# def456 - Add feature
# ghi789 - Update docs

# on main, only want the bug fix
git cherry-pick abc123

# only the bug fix is in main
# feature and docs are NOT
```

Useful for:
- Urgent hotfixes
- Backporting changes
- Taking one commit without whole branch

---

## Rebase (Reorganize History)

Rebase replays commits on top of another branch. Cleaner than merge.

```bash
# feature branch has commits
# but main has new commits too
git rebase main

# git replays feature commits on main
# result: linear, clean history

# switch to main
git checkout main
git merge feature
# fast-forward merge (no conflict)
```

Merge vs Rebase:

```
Merge:        Rebase:
main ─●─●     main ─●─●
 ╱   ╲ ╱       
feat ●─●        feat    ●─●

(creates merge commit) (linear history)
```

---

## Real Scenarios

### Scenario 1 — Multiple Developers

```bash
# Dev 1: feature-login
git checkout -b feature-login
# commits...

# Dev 2: feature-database
git checkout -b feature-database
# commits...

# Both merge to main
git checkout main
git merge feature-login
git merge feature-database

# Both features in production!
```

### Scenario 2 — Hotfix on Production

```bash
# Production is broken!
git checkout main
git checkout -b hotfix-critical

# fix bug
git commit -m "Fix critical bug"

# merge to main ASAP
git checkout main
git merge hotfix-critical

# customers get fix immediately
```

### Scenario 3 — Code Review

```bash
# Developer: works on feature
git checkout -b feature-payment
git commit -m "Add payment processing"

# Create Pull Request (on GitHub)
# Lead reviews the code, approves

# Merge only after approval
git merge feature-payment

# Code quality guaranteed
```

---

## Essential Commands

```bash
# Setup
git init                       # initialize repo
git config user.email "you@example.com"
git config user.name "Your Name"

# Daily
git status                     # see state
git add <file>                 # stage
git commit -m "message"        # save version
git log --oneline              # see history

# Branching
git checkout -b <branch>       # create and switch
git checkout <branch>          # switch
git branch -d <branch>         # delete
git merge <branch>             # merge

# Advanced
git cherry-pick <commit>       # copy commit
git rebase <branch>            # reorganize
git reset --hard <commit>      # undo to commit
git revert <commit>            # undo one commit

# Viewing
git diff                       # see changes
git show <commit>              # show commit details
git log --graph --all          # visual history
```

---

## Challenges Done

### Challenge 1 — Basic Workflow
Created repo, added files, made commits, saw history.

### Challenge 2 — Branching
Created multiple branches, switched between them,
saw how changes are isolated.

### Challenge 3 — Merging
Merged branches back to main,
handled merge conflicts.

### Challenge 4 — Cherry-Pick
Copied specific commits between branches.

### Challenge 5 — Rebase
Reorganized history for clean, linear timeline.

---

## Workflow Learned

```
1. Create feature branch
2. Make commits on branch
3. Switch to main
4. Merge feature in
5. Delete feature branch
6. Repeat

Simple. Powerful. Safe.
```

---

## Real DevOps with Git

This is how production works:

```
Code change → git commit
    ↓
Push to GitHub
    ↓
Tests run automatically
    ↓
Code review
    ↓
Approve and merge
    ↓
Automatic deployment
    ↓
Running in production

This is CI/CD (coming Day 25)
```

---

## Things That Clicked

- Branches let multiple people work simultaneously
- Commits are save points (not Ctrl+Z, but close)
- Merge combines branches
- Cherry-pick copies one commit
- Rebase replays commits (cleaner history)
- Conflicts happen, but they're manageable
- Git is how teams collaborate safely
- Every company uses Git

---

## Statistics

```
Day 22:
- Git concepts: 6 (init, commit, branch, merge, cherry-pick, rebase)
- Challenges: 5
- Commands learned: 20+
- Scenarios: 3
```

---
