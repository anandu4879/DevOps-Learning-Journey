#!/bin/bash
# Production Server Setup Script
# Uses: error handling, package management, config files, environment variables

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging
LOG="./serversetup_$(date +%Y%m%d_%H%M%S).log"

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"  | tee -a "$LOG"; }
log_done()  { echo -e "${GREEN}[DONE]${NC} $1" | tee -a "$LOG"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG"; }

# Cleanup on exit
cleanup() {
    log_info "Saving log to $LOG"
    echo "Setup completed at $(date)" >> "$LOG"
}
trap cleanup EXIT

# Validate arguments with getopts
ENVIRONMENT="development"
HOSTNAME_SET=""

usage() {
    echo "Usage: $0 -e <environment> -h <hostname> [-v]"
    echo "  -e  environment: development, staging, production"
    echo "  -h  hostname for the server"
    echo "  -v  verbose output"
    exit 1
}

while getopts "e:h:v" opt; do
    case $opt in
        e) ENVIRONMENT="$OPTARG" ;;
        h) HOSTNAME_SET="$OPTARG" ;;
        v) set -x ;;
        *) usage ;;
    esac
done

[[ -z "$HOSTNAME_SET" ]] && { log_error "Hostname required"; usage; }

# Validate environment
case "$ENVIRONMENT" in
    development|staging|production) ;;
    *) log_error "Invalid environment: $ENVIRONMENT"; exit 1 ;;
esac

log_info "Setting up server for $ENVIRONMENT environment"
log_info "Hostname: $HOSTNAME_SET"

# Step 1 — Update system
log_info "Updating system..."
sudo apt update > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1
log_done "System updated"

# Step 2 — Set hostname
log_info "Setting hostname..."
sudo hostnamectl set-hostname "$HOSTNAME_SET" > /dev/null 2>&1
log_done "Hostname set to $HOSTNAME_SET"

# Step 3 — Install packages using package management (Day 13)
log_info "Installing packages..."
PACKAGES=(
    "curl"
    "wget"
    "git"
    "vim"
    "htop"
    "tree"
    "net-tools"
    "build-essential"
    "python3"
    "python3-pip"
)

for pkg in "${PACKAGES[@]}"; do
    sudo apt install -y "$pkg" > /dev/null 2>&1 || {
        log_error "Failed to install $pkg"
        exit 1
    }
done
log_done "All packages installed"

# Step 4 — Create .env file (Day 12 — environment variables)
log_info "Creating .env file..."
cat > /tmp/server.env << EOF
ENVIRONMENT="$ENVIRONMENT"
HOSTNAME="$HOSTNAME_SET"
SETUP_DATE="$(date)"
SETUP_USER="$(whoami)"
EOF
log_done ".env file created"

# Step 5 — Archive and backup (Day 11 — archives)
log_info "Creating system backup..."
sudo tar -czf /tmp/server_backup_$(date +%Y%m%d).tar.gz /etc/ > /dev/null 2>&1
log_done "Backup created"

# Step 6 — Process verification (Day 05 & 13)
log_info "Verifying installations..."
TOOLS=("curl" "git" "python3" "vim")
for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        log_done "$tool installed"
    else
        log_error "$tool not found"
        exit 1
    fi
done

# Step 7 — Text processing analysis (Day 09)
log_info "Analyzing installed packages..."
PACKAGE_COUNT=$(apt list --installed 2>/dev/null | wc -l)
log_info "Total packages installed: $PACKAGE_COUNT"

# Step 8 — Storage info (Day 10)
log_info "Checking disk space..."
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
log_info "Disk usage: $DISK_USAGE"

# Summary
echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Server Setup Completed!${NC}"
echo -e "${GREEN}================================${NC}"
echo "Environment    : $ENVIRONMENT"
echo "Hostname       : $HOSTNAME_SET"
echo "Setup log      : $LOG"
echo "Backup created : /tmp/server_backup_$(date +%Y%m%d).tar.gz"
echo "Packages       : $PACKAGE_COUNT"
echo "Disk usage     : $DISK_USAGE"
echo -e "${GREEN}================================${NC}"