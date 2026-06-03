#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <folder_path>"
    exit 1
fi

DIR="$1"

if [ ! -d "$DIR" ]; then
    echo "Directory not found: $DIR"
    exit 1
fi

files_checked=0
issues_found=0

echo "Permission Audit Report"
echo "Directory: $DIR"
echo "================================================"

while read -r file; do
    perm_octal=$(stat -f "%Lp" "$file").   // For Linux, use: stat -c "%a" "$file"
    perm_string=$(stat -f "%Sp" "$file").  // For Linux, use: stat -c "%A" "$file"

    printf "%-50s %-4s %s\n" "$file" "$perm_octal" "$perm_string"

    ((files_checked++))

    # Others write bit set
    others_digit=${perm_octal: -1}

    if (( others_digit == 2 || others_digit == 3 || others_digit == 6 || others_digit == 7 )); then
        echo "  [ISSUE] World-writable"
        ((issues_found++))
    fi

    if [ "$perm_octal" = "777" ]; then
        echo "  [ISSUE] Permission is 777"
        ((issues_found++))
    fi

    if [[ "$file" == *.sh && ! -x "$file" ]]; then
        echo "  [ISSUE] Shell script not executable"
        ((issues_found++))
    fi

done < <(find "$DIR" -type f)

echo "================================================"
echo "Files checked : $files_checked"
echo "Issues found  : $issues_found"