# Day 09 — Text Processing Like a DevOps Engineer

If Day 03 was learning to use these tools, Day 09 is learning to think with
them. In real DevOps work you spend a huge amount of time staring at logs,
config files, and command output. The engineer who can slice through that
text fast is the one who finds the problem first.

---

## The Mental Model

```
Every problem leaves evidence in text.
Logs tell you what happened.
Config files tell you how things are set up.
Command output tells you the current state.

Your job is to extract the signal from the noise — fast.
```

```
grep  → find lines that match
sed   → transform lines
awk   → extract and compute columns
pipes → chain them together

input → grep (filter) → awk (extract) → sed (transform) → output
```

---

## `grep` — Investigation Tool

### Core flags

```bash
grep "error" app.log                # basic search
grep -i "error" app.log             # case insensitive
grep -n "error" app.log             # show line numbers
grep -v "error" app.log             # invert — lines NOT matching
grep -r "error" /var/log/           # recursive search
grep -c "error" app.log             # count matching lines only
grep -l "error" /var/log/*          # show only filenames that match
grep -w "error" app.log             # whole word — "errors" won't match
grep -o "error" app.log             # print only matched part not whole line
```

### Context lines — huge for debugging

```bash
grep -A 3 "ERROR" app.log           # 3 lines after match
grep -B 3 "ERROR" app.log           # 3 lines before match
grep -C 3 "ERROR" app.log           # 3 lines before AND after

# you don't just want the error line
# you want what happened just before it
grep -B 5 "FATAL" app.log
```

### Multiple patterns

```bash
grep -E "error|warning|fatal" app.log       # match either
grep "error" app.log | grep "database"      # match both
grep -v -E "DEBUG|INFO" app.log             # exclude multiple
```

### Real DevOps usage

```bash
# count errors per minute
grep "ERROR" app.log | awk '{print $1, $2}' | sort | uniq -c

# top IPs hitting your server
grep "GET\|POST" access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -10

# failed SSH attempts
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn

# watch live log and highlight errors
tail -f app.log | grep --color=always -E "ERROR|FATAL|$"
#                                                      ↑
#                              $ matches end of line
#                              so normal lines still show, errors are colored
```

---

## `sed` — Transform Lines

### Core syntax

```bash
sed 's/find/replace/' file          # replace first match per line
sed 's/find/replace/g' file         # replace ALL matches
sed 's/find/replace/gi' file        # case insensitive replace all

# edit file directly
sed -i '' 's/find/replace/g' file   # Mac
sed -i 's/find/replace/g' file      # Linux
```

### Beyond basic replace

```bash
# delete lines
sed '3d' file                       # delete line 3
sed '1,5d' file                     # delete lines 1 to 5
sed '/pattern/d' file               # delete lines matching pattern
sed '/^$/d' file                    # delete empty lines
sed '/^#/d' file                    # delete comment lines

# print specific lines
sed -n '5p' file                    # print only line 5
sed -n '10,20p' file                # print lines 10 to 20
sed -n '/ERROR/p' file              # print lines matching pattern

# add lines
sed '3a\new line here' file         # add line AFTER line 3
sed '3i\new line here' file         # insert line BEFORE line 3

# multiple operations
sed -e 's/foo/bar/g' -e 's/baz/qux/g' file

# extract block between two patterns
sed -n '/START/,/END/p' file
```

### Real DevOps uses

```bash
# update config value
sed -i 's/port=8080/port=9090/' config.properties

# remove comments and empty lines from config
sed '/^#/d' nginx.conf | sed '/^$/d'

# replace environment
sed -i "s/ENV=development/ENV=production/g" .env

# add line after a match
sed '/\[database\]/a host=192.168.1.20' config.ini

# strip ANSI color codes from log files
sed 's/\x1B\[[0-9;]*[mK]//g' colored.log
```

---

## `awk` — Column Processing and Computation

### How awk thinks

```bash
# awk processes line by line
# splits each line into fields
# $1=first field $2=second $NF=last field $0=entire line

echo "web-01 192.168.1.10 running 8080" | awk '{print $1}'      # web-01
echo "web-01 192.168.1.10 running 8080" | awk '{print $1, $3}'  # web-01 running
echo "web-01 192.168.1.10 running 8080" | awk '{print $NF}'     # 8080
```

### BEGIN and END blocks

```bash
awk '
BEGIN { print "Starting report..." }   # runs before any lines
{ print $1, $3 }                       # runs on every line
END   { print "Done" }                 # runs after all lines
' servers.txt
```

### Conditions

```bash
awk '$3 == "running"' file              # exact match
awk '$3 != "stopped"' file              # not equal
awk '$4 > 1000' file                    # numeric comparison
awk '/ERROR/' app.log                   # regex match
awk '!/DEBUG/' app.log                  # regex NOT match
awk 'NR > 1' file                       # skip first line
awk 'NR >= 5 && NR <= 10' file          # lines 5 to 10
```

### Math

```bash
# sum a column
awk '{sum += $4} END {print "Total:", sum}' file

# average
awk '{sum += $4; count++} END {print "Avg:", sum/count}' file

# count occurrences of each value
awk '{count[$3]++} END {for (k in count) print count[k], k}' file
```

### Custom separators

```bash
awk -F: '{print $1}' /etc/passwd        # colon separated
awk -F, '{print $2}' data.csv           # CSV
awk -F'\t' '{print $3}' data.tsv        # tab separated
awk -F'[,:]' '{print $1, $3}' file      # multiple separators
```

### Formatted output with printf

```bash
awk '{printf "%-15s %-15s %s\n", $1, $2, $3}' servers.txt
#            ↑
#            %-15s = left align, 15 chars wide
# output lines up neatly in columns
```

### Real DevOps uses

```bash
# extract specific fields from logs
awk '{print $1, $2, $4, $5}' app.log

# count log levels
awk '{count[$3]++} END {for (k in count) print k":", count[k]}' app.log

# find lines where response time > 1000ms
awk '$NF > 1000 {print $0}' access.log

# sum total bytes served
awk '{sum += $NF} END {print "Total bytes:", sum}' access.log

# print line number with errors
awk '/ERROR/ {print NR": "$0}' app.log
```

---

## Regex — The Language Underneath

### Character classes

```bash
.           any single character
[abc]       any of a, b, or c
[a-z]       any lowercase letter
[A-Z]       any uppercase letter
[0-9]       any digit
[^abc]      anything EXCEPT a, b, c
```

### Quantifiers

```bash
*           zero or more
+           one or more
?           zero or one (optional)
{3}         exactly 3
{3,}        3 or more
{3,6}       between 3 and 6
```

### Anchors

```bash
^           start of line
$           end of line
\b          word boundary
```

### Practical DevOps regex

```bash
# match IP address
grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' file

# extract only IP addresses — not the whole line
grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' file

# match date YYYY-MM-DD
grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}' file

# match port number
grep -E ':[0-9]{1,5}' file

# match HTTP status codes
grep -E 'HTTP/[0-9.]+ [0-9]{3}' access.log

# match email
grep -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file

# lines in a specific time range
grep -E '^2026-06-09 10:0[1-2]' app.log
```

---

## Chaining Tools Together

This is where real power comes from — combining tools:

```bash
# errors per hour
grep "ERROR" app.log | awk '{print $2}' | cut -d: -f1 | sort | uniq -c

# top 10 IPs
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10

# config value check
grep "^port" app.conf | awk -F= '{print $2}'

# find all unique endpoints with errors
grep "ERROR" app.log | grep -oE '/[a-zA-Z/]+' | sort | uniq -c | sort -rn

# count each log level
awk '{print $3}' app.log | sort | uniq -c | sort -rn
```

---

## Debugging Text Processing Issues

```bash
# problem — awk printing wrong column
# fix — count columns manually
echo "line here" | awk '{for(i=1;i<=NF;i++) print i, $i}'

# problem — grep not finding match
# fix — check if file has windows line endings
file myfile.txt         # shows if CRLF
cat -A myfile.txt       # shows ^ at line endings if Unix, ^M$ if Windows
sed -i 's/\r//' file    # remove Windows line endings

# problem — sed not replacing on Mac
# fix — Mac sed needs empty string after -i
sed -i '' 's/old/new/g' file    # Mac
sed -i 's/old/new/g' file       # Linux

# problem — awk giving wrong math results
# fix — awk does integer math by default
awk '{print 5/2}'       # prints 2 not 2.5
awk '{printf "%.2f\n", 5/2}'    # prints 2.50

# problem — grep -E vs grep
# fix — use -E for extended regex with + ? | {
grep -E 'error|warning' file    # works
grep 'error|warning' file       # might not work without -E
```

---

## Scripts Written Today

### `loganalyzer.sh`
Full log analysis tool — accepts a log file as argument with optional
filters for log level and time range. Produces a full report showing
total counts per level, error timeline, fatal events, and top issues.
Saves report to file if -r flag is given.

---

## Things That Tripped Me Up

- `grep -o` only prints the matched part not the whole line — really
  useful when you just want IPs or URLs out of a messy log line.
- `awk` field separator default is any whitespace — multiple spaces
  still count as one separator. Use `-F` to change it.
- `sed -i` on Mac needs `''` after it — `sed -i '' 's/a/b/g' file`.
  On Linux just `sed -i 's/a/b/g' file`. Caught me out every time.
- `uniq -c` only counts consecutive duplicates — always `sort` before
  `uniq` or you get wrong counts.
- `awk '{count[$3]++}'` — using an array as a counter is the most
  useful awk pattern in DevOps. Memorise this one.

---

## Quick Reference Card

```
Task                              Command
─────────────────────────────────────────────────────────────
Find lines matching pattern       grep "pattern" file
Find with context                 grep -C 3 "pattern" file
Count matches                     grep -c "pattern" file
Replace text                      sed 's/old/new/g' file
Delete lines matching             sed '/pattern/d' file
Print specific lines              sed -n '5,10p' file
Extract a column                  awk '{print $2}' file
Filter by column value            awk '$3 == "value"' file
Count occurrences                 awk '{c[$1]++} END{for(k in c) print c[k],k}'
Sum a column                      awk '{s+=$2} END{print s}'
Extract IPs                       grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}'
Top 10 most frequent              sort | uniq -c | sort -rn | head -10
Remove empty lines                sed '/^$/d'
Remove comment lines              sed '/^#/d'
```

---