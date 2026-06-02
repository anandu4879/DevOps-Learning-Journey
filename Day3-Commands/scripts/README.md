# Day 03 — Basic Commands, Text Processing & Pipes

Biggest day so far. Started with the commands I thought I already knew and
ended up going way deeper than expected. The pipes and text processing section
especially — once it clicked that you can chain commands together, everything
started feeling way more powerful.

---

## Basic Commands — Going Deeper

### `ls` — more than just listing files

```bash
ls -l               # long format — permissions, size, owner, date
ls -a               # show hidden files
ls -la              # both together
ls -lh              # human readable sizes
ls -lt              # sort by time, newest first
ls -lS              # sort by size, largest first
ls -R               # recursive — shows subfolders too
ls -1               # one item per line

ls -lah /etc        # list another folder without going into it
ls -lt /etc | head -6   # 5 most recently modified files
```

Reading the long format:
```
-rwxr-xr-x  2  anand  staff  4096  Jun 3  10:00  script.sh
↑            ↑  ↑      ↑      ↑     ↑              ↑
permissions links owner group  size  date           name
```

---

### `cd` — navigation

```bash
cd /etc             # absolute path — always from root
cd Documents        # relative path — from where you are
cd ..               # up one level
cd ../..            # up two levels
cd ~                # home directory
cd -                # back to previous directory
cd /                # root of the filesystem
```

---

### `pwd` — where am i

```bash
pwd                         # prints current path
echo "Running from: $(pwd)" # useful inside scripts
```

---

### `mkdir` — creating folders

```bash
mkdir myfolder
mkdir -p a/b/c/d                    # nested, no error if exists
mkdir -p project/{src,tests,docs}   # multiple at once
mkdir -m 755 sharedfolder           # create with permissions set
mkdir -v myfolder                   # verbose confirmation
```

---

### `rm` — deleting things

```bash
rm file.txt             # delete file — no undo, no recycle bin
rm -i file.txt          # asks before deleting
rm -f file.txt          # force, no error if not found
rm -r folder/           # delete folder recursively
rm -rf folder/          # force recursive — most dangerous command
rm -v file.txt          # shows what it deleted

# safe habit — always ls before rm -rf
ls folder/
rm -rf folder/
```

⚠️ `rm -rf /` deletes everything. Never run it.

---

### `cp` — copying

```bash
cp file.txt backup.txt          # copy and rename
cp file.txt folder/             # copy into folder
cp -r folder/ backup_folder/    # copy entire folder
cp -i file.txt backup.txt       # ask before overwriting
cp -p file.txt backup.txt       # preserve permissions and timestamps
cp -u file.txt backup.txt       # only copy if source is newer
cp -v file.txt backup.txt       # verbose

cp file1.txt file2.txt folder/  # copy multiple files
```

---

### `mv` — moving and renaming

```bash
mv old.txt new.txt          # rename
mv file.txt folder/         # move
mv folder/ /tmp/            # move entire folder
mv -i file.txt backup.txt   # ask before overwriting
mv -v file.txt folder/      # verbose

# rename multiple files with a loop
for f in *.txt; do mv "$f" "${f%.txt}.bak"; done
```

---

### `cat` — reading and creating files

```bash
cat file.txt                # print contents
cat -n file.txt             # with line numbers
cat file1.txt file2.txt     # print multiple files
cat file1.txt file2.txt > combined.txt  # merge files
cat file2.txt >> file1.txt  # append one file to another

# create file with content without opening an editor
cat > newfile.txt << EOF
line one
line two
line three
EOF
```

---

### `less` and `more` — reading large files

```bash
less file.txt       # scrollable file viewer — use this one
more file.txt       # older version, can't scroll up
```

Inside less:
```
j / ↓       scroll down
k / ↑       scroll up
space       page down
b           page up
g           go to top
G           go to bottom
/word       search forward
?word       search backward
n           next result
q           quit
```

---

### Other useful commands

```bash
head -n 5 file.txt      # first 5 lines
tail -n 5 file.txt      # last 5 lines
tail -f file.txt        # live follow — great for watching logs

wc file.txt             # lines, words, characters
wc -l file.txt          # just line count
wc -w file.txt          # just word count

file script.sh          # tells you what type a file is
which ls                # shows where a command lives
```

---

## Redirection & Pipes

This is where Linux becomes genuinely powerful. Everything can connect to
everything.

### Redirection

```bash
echo "hello" > file.txt         # write to file — overwrites
echo "world" >> file.txt        # append to file
ls /fake 2> errors.txt          # redirect errors to file
ls /fake 2>> errors.txt         # append errors
ls /fake &> all.txt             # redirect output AND errors
ls /fake 2> /dev/null           # throw errors away completely

wc -l < file.txt                # feed file as input
```

### Pipes `|`

Takes output of one command and feeds it into the next.

```bash
ls -la | less                           # scroll through ls
cat file.txt | sort | uniq              # sort and remove duplicates
ls /usr/bin | wc -l                     # count programs
ls /etc | grep "host"                   # filter results
du -h ~ | sort -rh | head -10          # top 10 largest items
ps aux | grep "bash"                    # find a process

# tee — show output AND save it at the same time
./script.sh | tee output.log
./script.sh | tee -a output.log         # append mode
```

---

## Wildcards

Match multiple files without typing each name.

```bash
*.txt               # all .txt files
file*               # everything starting with "file"
*backup*            # anything with "backup" in name
file?.txt           # file1.txt file2.txt — exactly one char
file[123].txt       # file1, file2, file3
file[1-5].txt       # file1 through file5
[A-Z]*.txt          # starts with uppercase
[!a]*.txt           # does NOT start with a

# {} expansion
touch file{1,2,3}.txt           # creates 3 files at once
mkdir {src,tests,docs}          # creates 3 folders
cp file.txt{,.bak}              # copies file.txt to file.txt.bak
```

---

## `find` — Search the Filesystem

```bash
# by name
find . -name "file.txt"
find . -name "*.sh" -type f
find / -name "passwd" 2>/dev/null

# by type
find . -type f          # files only
find . -type d          # folders only
find . -type l          # symlinks only

# by size
find . -size +1M        # larger than 1MB
find . -size -100k      # smaller than 100KB

# by time
find . -mtime -1        # modified in last 24 hours
find . -mtime +7        # older than 7 days
find . -newer file.txt  # newer than a specific file

# by permissions
find . -perm 755
find . -perm -u+x       # executable by owner

# find and do something
find . -name "*.sh" -exec chmod +x {} \;    # make all .sh executable
find . -name "*.log" -delete                # find and delete
find . -type f -exec ls -lh {} \;           # find and show details
```

---

## Text Processing

### `grep` — Search Inside Files

```bash
grep "word" file.txt            # basic search
grep -i "word" file.txt         # case insensitive
grep -n "word" file.txt         # show line numbers
grep -v "word" file.txt         # lines NOT matching
grep -c "word" file.txt         # count matches
grep -r "word" folder/          # search recursively
grep -l "word" *.txt            # show only filenames
grep -A 2 "word" file.txt       # 2 lines after match
grep -B 2 "word" file.txt       # 2 lines before match
grep -w "word" file.txt         # whole word only

# with pipes
ps aux | grep bash
ls -la | grep "^d"              # only directories
```

---

### `sed` — Find and Replace

```bash
sed 's/old/new/' file.txt           # replace first per line
sed 's/old/new/g' file.txt          # replace all
sed 's/old/new/gi' file.txt         # case insensitive

sed -i '' 's/old/new/g' file.txt    # edit file directly (Mac)
sed -i 's/old/new/g' file.txt       # edit file directly (Linux)

sed '3d' file.txt                   # delete line 3
sed '/word/d' file.txt              # delete lines with "word"
sed -n '5p' file.txt                # print only line 5
sed -n '1,5p' file.txt              # print lines 1 to 5
```

---

### `awk` — Column Processing

```bash
awk '{print $1}' file.txt           # first column
awk '{print $1, $3}' file.txt       # first and third
awk '{print $NF}' file.txt          # last column
awk -F: '{print $1}' /etc/passwd    # colon separated
awk -F, '{print $2}' data.csv       # CSV second column

awk '$3 > 100 {print $1}' file.txt  # conditional
awk 'NR==5' file.txt                # specific line
awk 'NR>=2 && NR<=5' file.txt       # line range

# math
awk '{sum += $1} END {print sum}' file.txt      # sum
awk '{sum += $1} END {print sum/NR}' file.txt   # average

# practical
df -h | awk '{print $1, $5}'        # disk name and usage
ls -lh | awk '{print $5, $9}'       # size and filename
```

---

## Scripts I Wrote Today

### `loginspect.sh`
Takes a file as argument, shows type, line count, first/last 5 lines,
lets you search inside it.

### `loganalyzer.sh`
Analyzes any log file — counts lines, finds top 5 frequent words,
searches by keyword, saves results to a report.

---

## Things That Tripped Me Up

- `sed -i` on Mac needs an empty string after it: `sed -i '' ...`
  On Linux you just do `sed -i` — caught me off guard
- `rm -rf` has no undo — always `ls` first before running it
- `awk` columns start at `$1` not `$0` — `$0` is the entire line
- Wildcards expand before the command runs — the shell does it,
  not the command itself

---

## Mac vs Linux Differences I Hit Today

| Task | Linux | Mac |
|------|-------|-----|
| Edit file with sed | `sed -i 's/a/b/g'` | `sed -i '' 's/a/b/g'` |
| RAM info | `free -h` | `top -l 1 \| grep PhysMem` |
| Log files | `/var/log/syslog` | `/var/log/system.log` |

---

#