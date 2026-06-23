#!/bin/bash

set -e

echo "=== Creating Group ==="

# Create group if it doesn't exist
getent group projectteam >/dev/null || groupadd projectteam

echo "=== Creating Users ==="

for user in dev1 dev2 auditor
do
    id "$user" >/dev/null 2>&1 || useradd -m "$user"
done

# Add dev users to project team
usermod -aG projectteam dev1
usermod -aG projectteam dev2

echo "=== Creating Directory Structure ==="

mkdir -p /opt/project/{shared,scripts,private}

echo "=== Setting Ownership ==="

chown root:projectteam /opt/project/shared
chown root:projectteam /opt/project/scripts
chown root:root /opt/project/private

echo "=== Setting Permissions ==="

# shared/
# Owner rwx
# Group rwx
# Others none
# Sticky bit enabled

chmod 1770 /opt/project/shared

# scripts/
# Owner rwx
# Group r-x
# Others none
# SGID enabled

chmod 2750 /opt/project/scripts

# private/
# Owner only

chmod 700 /opt/project/private

echo "=== Configuring ACLs ==="

# auditor gets read-only access

setfacl -m u:auditor:rx /opt/project/shared
setfacl -m u:auditor:rx /opt/project/scripts

# Ensure no access to private
setfacl -m u:auditor:--- /opt/project/private

echo
echo "======================================="
echo "PROJECT ENVIRONMENT CREATED"
echo "======================================="

echo
echo "Users:"
id dev1
id dev2
id auditor

echo
echo "Directory Permissions"
echo "---------------------------------------"

ls -ld /opt/project/shared
ls -ld /opt/project/scripts
ls -ld /opt/project/private

echo
echo "ACL: shared"
echo "---------------------------------------"
getfacl /opt/project/shared

echo
echo "ACL: scripts"
echo "---------------------------------------"
getfacl /opt/project/scripts

echo
echo "ACL: private"
echo "---------------------------------------"
getfacl /opt/project/private

echo
echo "Setup Complete."