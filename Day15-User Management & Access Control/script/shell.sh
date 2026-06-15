#!/bin/bash
# usertools.sh - manage users safely

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[DONE]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Help
usage() {
    cat << EOF
Usage: $0 [command] [options]

Commands:
  create <username>       - Create new user
  delete <username>       - Delete user
  addgroup <user> <group> - Add user to group
  list                    - List all users
  info <username>         - Show user info
  help                    - Show this help

Examples:
  $0 create alice
  $0 addgroup alice developers
  $0 info alice
  $0 list
EOF
    exit 0
}

# Create user
create_user() {
    local user=$1
    [[ -z "$user" ]] && error "Username required"
    
    log "Creating user $user..."
    sudo useradd -m -s /bin/bash "$user" || error "User already exists"
    
    log "Set password for $user"
    sudo passwd "$user" || error "Failed to set password"
    
    success "User $user created"
    id "$user"
}

# Delete user
delete_user() {
    local user=$1
    [[ -z "$user" ]] && error "Username required"
    
    log "Deleting user $user..."
    sudo userdel -r "$user" || error "User doesn't exist"
    
    success "User $user deleted"
}

# Add user to group
add_to_group() {
    local user=$1
    local group=$2
    [[ -z "$user" || -z "$group" ]] && error "User and group required"
    
    log "Adding $user to $group..."
    
    # Create group if doesn't exist
    sudo groupadd "$group" 2>/dev/null || true
    
    # Add user
    sudo usermod -aG "$group" "$user" || error "Failed to add user to group"
    
    success "$user added to $group"
    id "$user"
}

# List users (excluding system accounts)
list_users() {
    log "Users on system:"
    awk -F: '$3 >= 1000 {print $1}' /etc/passwd
}

# Show user info
show_info() {
    local user=$1
    [[ -z "$user" ]] && error "Username required"
    
    log "Info for $user:"
    id "$user"
    grep "^$user" /etc/passwd
    grep "^$user" /etc/group || true
}

# Main
[[ $# -eq 0 ]] && usage

case "$1" in
    create)  create_user "$2" ;;
    delete)  delete_user "$2" ;;
    addgroup) add_to_group "$2" "$3" ;;
    list)    list_users ;;
    info)    show_info "$2" ;;
    help|*)  usage ;;
esac