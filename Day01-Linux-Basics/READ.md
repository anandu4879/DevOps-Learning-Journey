# Day 01 — Linux Basics & Terminal

First day properly sitting down with Linux. I've used the terminal before but
mostly copy-pasting commands I didn't fully understand. Today was about actually
knowing what I'm typing and why.

---

## What I learned

### Linux isn't an OS — it's a kernel
The kernel is the core that talks to hardware. What we call Linux (Ubuntu,
Fedora, etc.) is the kernel + tools + package manager bundled together. Linus
Torvalds wrote it in 1991 as a hobby project. That hobby now runs most of the
internet.

### Distros — why there are so many
Each distro is basically a different opinion on how Linux should be packaged.
- **Ubuntu** — beginner friendly, huge community
- **Fedora** — more cutting edge, good for developers
- **Arch** — you build it yourself, total control
- **Kali** — pre-loaded security tools
- **CentOS** — what you find on enterprise servers

I'm on a Mac so I'm using KodeKloud's browser terminal for actual Linux practice.

---

## Commands I practiced

```bash
whoami          # prints your username
hostname        # machine name
pwd             # where you are right now
df -h           # disk usage
df -h | grep disk3s5   # filter to just the main drive
free -h         # RAM — Linux only, Mac uses:
top -l 1 | grep PhysMem

ls -la          # list everything including hidden files
mkdir -p day01/{notes,scripts,practice}   # create nested folders in one shot
touch file.txt  # create empty file
echo "text" > file.txt    # write to file (overwrites)
echo "text" >> file.txt   # append to file
cat file.txt    # read file
cp file.txt folder/       # copy
mv file.txt newname.txt   # rename or move
rm file.txt     # delete — no undo
find day01 -type f        # list all files recursively
```

---

## Permissions

```bash
chmod 600 secret.txt    # only owner can read/write
chmod 755 script.sh     # owner full, everyone else read/execute

ls -l secret.txt
# -rw-------  (600)

ls -l script.sh
# -rwxr-xr-x  (755)
```

The numbers are read(4) + write(2) + execute(1) added together per group.
So 7 = full access, 6 = read/write, 5 = read/execute, 4 = read only.

---

## Boss challenge output

Built a system report using only terminal commands — no text editor:

```
anandupradeep
Anandus-MacBook-Pro.local
Mon Jun  1 03:56:39 IST 2026
/dev/disk3s5     228Gi   123Gi    82Gi    61%    1.5M  859M    0%   /System/Volumes/Data
PhysMem: 7550M used (1295M wired, 2998M compressor), 80M unused.
```

---

## What tripped me up

- `free -h` doesn't exist on Mac — use `top -l 1 | grep PhysMem` instead
- `df -h` on Mac shows a lot of internal Apple volumes — filter with `grep` to
  get only what you need
- Mac runs BSD Unix under the hood, not Linux — most commands work but some
  don't

