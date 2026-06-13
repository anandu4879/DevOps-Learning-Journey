#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <file-name>"
    exit 1
fi
FILE=$1

if [ ! -f "$FILE" ]; then
    echo "Error: File does not exist!"
    exit 1
fi
echo "File Type:"
file "$FILE"
echo
echo "Total Line Count:"
wc -l < "$FILE"
echo
echo "First 5 Lines:"
head -n 5 "$FILE"
echo
echo "Last 5 Lines:"
tail -n 5 "$FILE"
echo
read -p "Enter a search word: " WORD
echo
echo "Matching Lines:"
grep "$WORD" "$FILE"

