# Git Cheat Sheet

## Basic
git init                    # initialize repo
git add <file>             # stage file
git commit -m "message"    # commit changes
git log                    # see history
git status                 # see current state

## Branching
git branch                 # list branches
git checkout -b <branch>   # create and switch
git checkout <branch>      # switch branch
git merge <branch>         # merge into current
git branch -d <branch>     # delete branch

## Advanced
git cherry-pick <commit>   # copy specific commit
git rebase <branch>        # replay commits
git reset --hard <commit>  # undo to commit
git revert <commit>        # undo one commit

## View
git log --oneline          # short history
git log --graph --all      # visual history
git diff                   # see changes
git show <commit>          # show commit details