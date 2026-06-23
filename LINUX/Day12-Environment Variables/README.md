# Day 12 — Environment Variables & Shell Configuration

Understanding environment variables is understanding how your shell
actually works. Everything depends on them — PATH, HOME, configuration.

---

## What Are Environment Variables?

Key/value pairs that your shell and programs can read.

```bash
echo $PATH          # list of folders to search for commands
echo $HOME          # your home directory
echo $USER          # your username
echo $SHELL         # which shell you're using

# see all of them
env
printenv
```

---

## PATH — The Most Important One

When you type `ls`, your shell searches PATH for it.

```bash
echo $PATH
# /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# shell searches in that order, first match wins
which ls            # shows which one you're actually running
```

### Add to PATH (temporary)

```bash
export PATH="/my/custom/bin:$PATH"
#                        ↑ keep existing PATH
```

### Add to PATH (permanent)

Add to `~/.zshrc` or `~/.bashrc`:
```bash
export PATH="/my/custom/bin:$PATH"
```

---

## Set & Export

```bash
MY_VAR="value"                  # set — just this shell
export MY_VAR="value"           # export — inherited by all commands

bash -c 'echo $MY_VAR'          # export needed for child to see it
```

---

## Shell Startup Files

When you open a terminal it reads:

```
~/.bashrc       for bash
~/.zshrc        for zsh
```

Put export statements and aliases there — they run automatically.

```bash
# edit your file
nano ~/.zshrc

# add these
export MY_VAR="value"
alias ll='ls -lh'

# reload without restarting
source ~/.zshrc
```

---

## Common Customizations

### Aliases

```bash
alias ll='ls -lh'
alias gs='git status'
alias gp='git push'
alias deploy='cd ~/projects/app && git pull && npm install && npm run build'
```

### Functions

```bash
# make folder and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# navigate projects quickly
proj() {
    cd ~/projects/$1 || echo "not found"
}
```

### Add to PATH

```bash
export PATH="~/my_scripts:$PATH"
```

### Git Config

```bash
export GIT_AUTHOR_NAME="Your Name"
export GIT_AUTHOR_EMAIL="your@email.com"
```

---

## `.env` Files for Apps

Applications read configuration from `.env` files instead of hardcoding.

```bash
# create .env
cat > .env << 'EOF'
DATABASE_URL="postgresql://localhost/mydb"
API_KEY="secret123"
PORT=8080
NODE_ENV="development"
EOF

# app reads on startup using dotenv library
# Python: python-dotenv
# Node: dotenv package

# NEVER commit .env to git
echo ".env" >> .gitignore

# commit template instead
echo ".env.example" to git
```

---

## Real DevOps Patterns

### Deploy Script

```bash
#!/bin/bash
source .env    # load configuration

echo "Deploying to $ENVIRONMENT"
echo "Database: $DATABASE_URL"

systemctl restart myapp
```

### Make Commands Global

```bash
# create script
cat > ~/my_scripts/hello.sh << 'EOF'
#!/bin/bash
echo "Hello from $0"
EOF

chmod +x ~/my_scripts/hello.sh

# add to PATH in ~/.zshrc
export PATH="~/my_scripts:$PATH"

# now works everywhere
hello.sh
```

### Project-Specific Setup

```bash
# in ~/.zshrc
export JAVA_HOME="/opt/java"
export ANDROID_HOME="$HOME/Android/sdk"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/tools:$PATH"

# now java and android tools work everywhere
java -version
adb devices
```

---

## Challenges Done

### Challenge 1 — Explore Variables
Printed PATH, counted folders in it, checked if folders exist,
found where Python lives.

### Challenge 2 — Export Practice
Set variables with and without export, verified children inherit only
exported ones.

### Challenge 3 — Make Command Global
Created script, added folder to PATH, made command available everywhere.

### Challenge 4 — Customize Shell
Added aliases, functions, and PATH updates to .zshrc and tested them.

### Challenge 5 — Use .env
Created .env file, wrote script that reads it, verified app uses config.

---

## Things That Clicked

- PATH is just a list of folders — shell searches them in order
- export makes variables inherited — without it child processes don't see them
- .zshrc / .bashrc runs every time you open a terminal — perfect place for setup
- .env files separate code from configuration — app doesn't need to know about passwords
- aliases are just shortcuts — `alias deploy='long command'` saves a lot of typing

---

## Mac vs Linux

| Item | Mac | Linux |
|------|-----|-------|
| Startup file | ~/.zshrc (newer) or ~/.bash_profile | ~/.bashrc or ~/.zshrc |
| PATH separator | : | : (same) |
| export syntax | export VAR="value" | export VAR="value" (same) |
| which command | which | which (same) |

Everything is the same — environment variables work identically.

---

## Sample Starter Config

Here's what a good `.zshrc` looks like:

```bash
# aliases
alias ll='ls -lah'
alias gs='git status'
alias gp='git push'
alias gd='git diff'

# functions
mkcd() { mkdir -p "$1" && cd "$1"; }
proj() { cd ~/projects/$1; }

# environment
export EDITOR="nano"
export PATH="~/my_scripts:$PATH"
export GIT_AUTHOR_NAME="Your Name"
export GIT_AUTHOR_EMAIL="your@email.com"

# custom prompt (optional)
export PS1="\u@\h:\W\$ "
```

---
