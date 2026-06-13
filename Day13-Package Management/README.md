# Day 13 — Package Management

Today was about understanding the tools that install software.
Package managers are the reason you don't spend hours compiling code.
They handle dependencies automatically and make updates easy.

---

## The Concept

Package Manager = software installer that handles dependencies automatically.

```
Package Repository (internet)
    ↓ downloads
Package (pre-compiled, compressed)
    ↓ extracts
System (/usr/bin, /usr/lib, /etc)
    ↓
App works
```

---

## Three Main Package Managers

### `apt` — Ubuntu/Debian

```bash
# update package list
sudo apt update

# upgrade installed packages
sudo apt upgrade

# install
sudo apt install package_name

# remove
sudo apt remove package_name

# search
apt search package_name

# show info
apt show package_name

# list installed
apt list --installed

# see what's outdated
apt list --upgradable

# hold package (prevent upgrade)
sudo apt-mark hold package_name
sudo apt-mark unhold package_name

# clean old cache
sudo apt clean
sudo apt autoclean
```

### `yum` / `dnf` — RHEL/CentOS

```bash
# update
sudo yum update

# install
sudo yum install package_name

# remove
sudo yum remove package_name

# search
yum search package_name

# show info
yum info package_name

# list installed
yum list installed

# dnf is newer, same commands
sudo dnf install package_name
```

### `brew` — Mac

```bash
# update brew itself
brew update

# upgrade installed packages
brew upgrade

# install
brew install package_name

# remove
brew uninstall package_name

# search
brew search package_name

# show info
brew info package_name

# list installed
brew list

# cleanup
brew cleanup
```

---

## Dependencies — Automatic Magic

When you install a package, it automatically installs what it needs.

```bash
# example
sudo apt install nodejs

# nodejs depends on:
# - libssl3
# - libc6
# - etc

# apt installs all of them automatically
# you don't have to think about it
```

Check what a package depends on:
```bash
apt-cache depends python3
brew info nodejs | grep -i depend
yum info python3 | grep -i depend
```

---

## Versions — Install Specific or Lock

### See Versions

```bash
# what versions are available?
apt-cache policy nodejs
apt-cache policy python3

# which version is installed?
apt-cache policy nodejs | grep "Installed"
```

### Install Specific Version

```bash
# apt
sudo apt install nodejs=12.0.0

# yum
sudo yum install nodejs-12.0.0

# brew — doesn't have easy version pinning
# brew philosophy is "always use latest"
```

### Lock Package (Don't Update)

Production servers sometimes need locked versions for stability.

```bash
# apt
sudo apt-mark hold postgresql
# now apt upgrade won't touch postgresql

# unhold when ready
sudo apt-mark unhold postgresql
```

---

## Where Files Go

When you install a package, files scatter everywhere:

```bash
# binary (the program itself)
/usr/bin/python3
/usr/local/bin/node

# libraries (code the program depends on)
/usr/lib/x86_64-linux-gnu/
/opt/homebrew/lib

# config files
/etc/nginx/nginx.conf
/etc/postgresql/

# data files
/var/lib/postgresql/
```

See what a package installed:
```bash
# apt
dpkg -L python3              # all files package installed

# yum
rpm -ql python3

# brew
brew list nodejs
```

---

## Real DevOps Scenarios

### Fresh Server Setup Script

```bash
#!/bin/bash
sudo apt update
sudo apt upgrade -y

# essential tools
sudo apt install -y curl wget git vim htop nginx postgresql docker.io

# enable services
sudo systemctl enable nginx postgresql docker
sudo systemctl start nginx postgresql docker

echo "Server ready"
```

### Pin Critical Packages

On production database servers, don't allow automatic updates:

```bash
# pin postgresql
sudo apt-mark hold postgresql

# later when tested
sudo apt-mark unhold postgresql
sudo apt upgrade
```

### Automate Server Configuration

Write once, run on every new server:

```bash
#!/bin/bash
set -euo pipefail

# update
sudo apt update
sudo apt upgrade -y

# install essentials
PACKAGES=("curl" "git" "vim" "htop" "docker.io" "postgresql")

for pkg in "${PACKAGES[@]}"; do
    sudo apt install -y "$pkg"
done

# start services
sudo systemctl enable docker postgresql
sudo systemctl start docker postgresql

echo "Done"
```

---

## Challenges Done

### Challenge 1 — Install Software
On KodeKloud, searched for packages, installed them, verified they work,
found where they're installed, removed them.

### Challenge 2 — Install on Mac
Installed packages with brew, verified they work, found their location,
and uninstalled them.

### Challenge 3 — Version Management
Checked available versions, held packages to prevent automatic updates,
verified what's outdated.

---

## Scripts Written

### `setup-server.sh`
Complete production server setup — updates system, installs tools,
enables services, verifies everything works. Run once on a fresh server
and it's ready to go.

---

## Things That Clicked

- Package managers automate everything — dependencies, updates, removal
- `apt update` doesn't upgrade anything — it just downloads the list
- Always `apt update` before `apt upgrade`
- Holding packages on production servers prevents breaking changes
- dpkg -L shows exactly what files a package installed
- Dependency hell is rare now — modern package managers handle it well
- ldd shows all libraries a program depends on

---

## apt vs yum vs brew

| Task | apt | yum | brew |
|------|-----|-----|------|
| Update list | `apt update` | `yum update` | `brew update` |
| Upgrade all | `apt upgrade` | `yum update` | `brew upgrade` |
| Install | `apt install pkg` | `yum install pkg` | `brew install pkg` |
| Remove | `apt remove pkg` | `yum remove pkg` | `brew uninstall pkg` |
| Search | `apt search pkg` | `yum search pkg` | `brew search pkg` |
| Info | `apt show pkg` | `yum info pkg` | `brew info pkg` |
| List installed | `apt list --installed` | `yum list installed` | `brew list` |

---

## Common Packages to Know

```
curl       → make HTTP requests from terminal
wget       → download files
git        → version control
vim        → text editor
htop       → system monitor
docker     → containers
postgresql → database
redis      → cache
nodejs     → JavaScript runtime
python3    → Python interpreter
nginx      → web server
```

---

## KodeKloud
- Package Management Lab ✅
