#!/bin/bash

# Create test directory
mkdir -p test-perms

echo "Creating test files..."

# Normal file (no issues)
touch test-perms/normal.txt
chmod 644 test-perms/normal.txt

# World writable file
touch test-perms/world_writable.txt
chmod 666 test-perms/world_writable.txt

# 777 file
touch test-perms/full_access.txt
chmod 777 test-perms/full_access.txt

# Non-executable shell script
cat > test-perms/deploy.sh <<EOF
#!/bin/bash
echo "Deploying application..."
EOF
chmod 644 test-perms/deploy.sh

# Executable shell script
cat > test-perms/backup.sh <<EOF
#!/bin/bash
echo "Running backup..."
EOF
chmod 755 test-perms/backup.sh

# Private file
touch test-perms/private.txt
chmod 600 test-perms/private.txt

# Group writable file
touch test-perms/group_write.txt
chmod 664 test-perms/group_write.txt

echo
echo "Test environment created successfully."
echo
echo "Current permissions:"
ls -l test-perms
echo
echo "Run your audit script with:"
echo "./perm_audit.sh test-perms"