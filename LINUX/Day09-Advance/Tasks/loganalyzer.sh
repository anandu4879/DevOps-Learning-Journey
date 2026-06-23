#!/bin/bash

show_help() {
cat << EOF
Usage: $0 -f <logfile> [-l <level>] [-s <start>] [-e <end>] [-r <report>]

Options:
-f  Log file (required)
-l  Filter level (INFO|WARN|ERROR|FATAL)
-s  Start time HH:MM:SS
-e  End time HH:MM:SS
-r  Save report to file
-h  Show help
EOF
exit 0
}

LOGFILE=""
LEVEL=""
START_TIME=""
END_TIME=""
REPORT_FILE=""

# Section 1 — getopts

while getopts ":f:l:s:e:r:h" opt; do
case $opt in
f) LOGFILE="$OPTARG" ;;
l) LEVEL="$OPTARG" ;;
s) START_TIME="$OPTARG" ;;
e) END_TIME="$OPTARG" ;;
r) REPORT_FILE="$OPTARG" ;;
h) show_help ;;
*) echo "Invalid option"; exit 1 ;;
esac
done

# Section 2 — validate file exists

if [[ -z "$LOGFILE" ]]; then
echo "ERROR: logfile required"
exit 1
fi

if [[ ! -f "$LOGFILE" ]]; then
echo "ERROR: file not found: $LOGFILE"
exit 1
fi

TMPFILE=$(mktemp)

cp "$LOGFILE" "$TMPFILE"

# Optional level filter

if [[ -n "$LEVEL" ]]; then
grep "$LEVEL" "$TMPFILE" > "${TMPFILE}.tmp"
mv "${TMPFILE}.tmp" "$TMPFILE"
fi

# Optional time range filter

if [[ -n "$START_TIME" && -n "$END_TIME" ]]; then
awk -v start="$START_TIME" -v end="$END_TIME" '
{
if ($2 >= start && $2 <= end)
print
}' "$TMPFILE" > "${TMPFILE}.tmp"

```
mv "${TMPFILE}.tmp" "$TMPFILE"
```

fi

{
echo "=========================================="
echo "  Log Analysis Report"
echo "  File: $LOGFILE"
echo "  Generated: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="
echo

# Section 3 — count levels

echo "[Summary]"

TOTAL=$(wc -l < "$TMPFILE")

INFO_COUNT=$(awk '$3=="INFO"{c++} END{print c+0}' "$TMPFILE")
WARN_COUNT=$(awk '$3=="WARN"{c++} END{print c+0}' "$TMPFILE")
ERROR_COUNT=$(awk '$3=="ERROR"{c++} END{print c+0}' "$TMPFILE")
FATAL_COUNT=$(awk '$3=="FATAL"{c++} END{print c+0}' "$TMPFILE")

echo "Total lines    : $TOTAL"
echo "INFO count     : $INFO_COUNT"
echo "WARN count     : $WARN_COUNT"
echo "ERROR count    : $ERROR_COUNT"
echo "FATAL count    : $FATAL_COUNT"

# Section 4 — time range

START=$(awk 'NR==1 {print $2}' "$TMPFILE")
END=$(awk 'END {print $2}' "$TMPFILE")

echo "Time range     : $START to $END"
echo

# Section 5 — error timeline

echo "[Error Timeline]"

grep "ERROR" "$TMPFILE" | 
awk '{
printf "%s  ", $2
for(i=4;i<=NF;i++)
printf "%s ", $i
printf "\n"
}'

echo

# Section 6 — fatal events

echo "[Fatal Events]"

grep "FATAL" "$TMPFILE" | 
awk '{
printf "%s  ", $2
for(i=4;i<=NF;i++)
printf "%s ", $i
printf "\n"
}'

echo

# Section 7 — top issues

echo "[Top Issues]"

grep "ERROR" "$TMPFILE" | 
sed -E 's/^[0-9-]+ [0-9:]+ ERROR //' | 
sed -E 's#/api/[^ ]+##g' | 
sort | uniq -c | sort -nr

} | tee "${REPORT_FILE:-/dev/stdout}"

# Section 8 — save report

if [[ -n "$REPORT_FILE" ]]; then
echo
echo "Report saved to: $REPORT_FILE"
fi

rm -f "$TMPFILE"
exit 0
