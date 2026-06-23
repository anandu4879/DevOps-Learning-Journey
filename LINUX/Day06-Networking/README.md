# Day 06 — Networking Basics

This one felt different from everything before it. Permissions and processes
are about your own machine — networking is about your machine talking to the
entire world. As someone getting into DevOps this is probably the topic I'll
use every single day on the job.

---

## How a DevOps Engineer Thinks About Networking

When something breaks the checklist in your head should always go like this:

```
1. Is the machine reachable?          → ping
2. Is the port open?                  → nc / telnet
3. Is the service listening?          → netstat / ss
4. Is DNS resolving correctly?        → nslookup / dig
5. Is the request actually going out? → curl / wget
6. What route is the traffic taking?  → traceroute
```

That mental model alone solves 80% of network problems you'll ever hit.

---

## Your Machine's Network Identity

```bash
ifconfig                        # Mac and older Linux — all interfaces
ip addr                         # modern Linux — shorter: ip a
ip a | grep "inet "             # just IP addresses

# interfaces you'll see
# lo       — loopback, 127.0.0.1 — machine talking to itself
# eth0     — wired connection
# wlan0    — wifi (Linux)
# en0      — wifi (Mac)

# default gateway — where traffic goes to reach the internet
netstat -rn
ip route

# DNS servers your machine is using
cat /etc/resolv.conf            # Linux
scutil --dns | grep nameserver  # Mac
```

---

## `ping` — Is It Alive?

ping sends an ICMP Echo Request packet and waits for an ICMP Echo Reply.
The whole round trip gets timed in milliseconds.

```bash
ping google.com                 # ping forever — Ctrl+C to stop
ping -c 4 google.com            # exactly 4 times
ping -c 4 8.8.8.8               # ping by IP — bypasses DNS
ping -i 2 google.com            # ping every 2 seconds
ping -q -c 10 google.com        # quiet mode — summary only
ping -s 1000 google.com         # send larger packets — test capacity
```

Reading the output:
```
64 bytes from 142.250.67.14: icmp_seq=1 ttl=118 time=14.2 ms
                               ↑          ↑       ↑
                               │          │       └── round trip time
                               │          └────────── hops remaining
                               └───────────────────── server IP

--- ping summary ---
4 packets transmitted, 4 received, 0% packet loss
round-trip min/avg/max = 13.8/14.1/14.5 ms
```

Response time guide:
```
under 50ms    → great
50 to 150ms   → acceptable
over 150ms    → slow, investigate
timeout       → host unreachable or blocking ICMP
```

### ping as a DevOps diagnostic tool

```bash
# step 1 — is our server alive at all?
ping -c 3 192.168.1.10

# step 2 — is internet working from this server?
ping -c 3 8.8.8.8

# step 3 — is DNS working?
# if 8.8.8.8 works but google.com doesn't → DNS problem
ping -c 3 google.com
```

### ping deep dive — what TTL tells you

TTL (Time To Live) starts at 64 or 128 depending on the OS and decreases
by 1 at every router hop. When it hits 0 the packet gets dropped. This
prevents packets from looping forever on the internet.

```
TTL in response ≈ 64   → Linux machine (started at 64)
TTL in response ≈ 118  → Windows or Google (started at 128, took ~10 hops)
TTL in response ≈ 254  → Network device (started at 255)
```

---

## `netstat` and `ss` — What's Listening?

```bash
# ss — modern and faster, use this one
ss -tuln             # TCP+UDP, listening ports, numeric
ss -tulnp            # + which process owns the port
ss -ta               # all TCP connections including established
ss -s                # summary statistics

# netstat — older but still everywhere
netstat -tuln        # same as ss -tuln
netstat -tulnp       # with process names — needs sudo
netstat -rn          # routing table
netstat -an          # all connections numeric

# find what's on a specific port
ss -tulnp | grep :80
ss -tulnp | grep :22
ss -tulnp | grep :8080

# find what ports a specific service is using
ss -tulnp | grep nginx
ss -tulnp | grep python
```

Reading the output:
```
Netid  State   Recv-Q  Send-Q  Local Address:Port  Peer Address
tcp    LISTEN  0       128     0.0.0.0:22           0.0.0.0:*
                                ↑       ↑
                                │       └── port 22 (SSH)
                                └── 0.0.0.0 means all interfaces
```

---

## DNS Basics

DNS is the phonebook of the internet. You type a domain name, DNS
translates it to an IP address.

How it works:
```
You type google.com
      ↓
Check /etc/hosts first (local overrides)
      ↓
Ask your DNS server (usually your router)
      ↓
If not cached → root DNS → .com DNS → google.com DNS
      ↓
Returns 142.250.67.14
      ↓
Browser connects to that IP
```

```bash
# nslookup — simple DNS lookup
nslookup google.com
nslookup google.com 8.8.8.8     # use specific DNS server

# dig — more detailed
dig google.com
dig google.com A                 # IPv4 address record
dig google.com MX                # mail server records
dig google.com NS                # nameserver records
dig +short google.com            # just the IP
dig @8.8.8.8 google.com         # query specific DNS server
dig -x 8.8.8.8                  # reverse lookup — IP to hostname

# local DNS files
cat /etc/hosts                   # checked before DNS — local overrides
cat /etc/resolv.conf             # which DNS servers to use
```

Common DNS record types:
```
A       → domain to IPv4 address
AAAA    → domain to IPv6 address
MX      → mail server for domain
CNAME   → alias for another domain
NS      → nameservers for domain
TXT     → text records (used for verification)
PTR     → reverse lookup — IP to domain
```

---

## `curl` — Talk to Servers

The most used tool in DevOps. Makes any HTTP request from the terminal.

```bash
# basic GET request
curl https://google.com

# show only response headers
curl -I https://google.com

# show full request and response details
curl -v https://google.com

# follow redirects
curl -L https://google.com

# save output to file
curl -o page.html https://google.com
curl -O https://example.com/file.zip    # keep original filename

# POST with JSON body
curl -X POST https://api.example.com \
  -H "Content-Type: application/json" \
  -d '{"name": "anand"}'

# with auth header
curl -H "Authorization: Bearer mytoken" https://api.example.com

# check response time
curl -o /dev/null -s -w "%{time_total}\n" https://google.com

# check just HTTP status code
curl -o /dev/null -s -w "%{http_code}\n" https://google.com

# test if a port is open
curl -v telnet://192.168.1.10:22
```

HTTP status codes you need to know:
```
200   OK — worked perfectly
201   Created — resource was created
301   Moved Permanently — redirect
400   Bad Request — something wrong with your request
401   Unauthorized — need to authenticate
403   Forbidden — authenticated but no permission
404   Not Found — resource doesn't exist
500   Internal Server Error — something broken on the server
502   Bad Gateway — upstream server issue
503   Service Unavailable — server overloaded or down
```

---

## `wget` — Download Files

```bash
wget https://example.com/file.zip               # download file
wget -q https://example.com/file.zip            # quiet mode
wget -O myfile.zip https://example.com/file.zip # save with custom name
wget -c https://example.com/bigfile.zip         # resume interrupted download
wget -r https://example.com                     # download entire site
wget --spider https://example.com/file.zip      # check if URL exists
```

curl vs wget:
```
curl    → API calls, sending data, headers, scripting
wget    → downloading files, resuming, mirroring sites
```

---

## SSH — Remote Connections

As a DevOps engineer you'll spend a huge amount of time SSHed into
remote servers. This is non-negotiable to get comfortable with.

```bash
# connect to a server
ssh username@hostname
ssh anand@192.168.1.10
ssh anand@server.example.com

# different port
ssh -p 2222 anand@192.168.1.10

# run a command remotely without opening a shell
ssh anand@192.168.1.10 "df -h"
ssh anand@192.168.1.10 "systemctl status nginx"

# copy files to remote
scp file.txt anand@192.168.1.10:/home/anand/
scp -r folder/ anand@192.168.1.10:/home/anand/

# copy from remote to local
scp anand@192.168.1.10:/var/log/app.log .
```

### SSH keys — the right way

```bash
# generate a key pair
ssh-keygen -t ed25519 -C "anand@macbook"
# creates two files:
# ~/.ssh/id_ed25519      ← private key — NEVER share this
# ~/.ssh/id_ed25519.pub  ← public key — this goes on the server

# copy public key to server
ssh-copy-id anand@192.168.1.10

# private key must be 600 — SSH refuses if it's too open
chmod 600 ~/.ssh/id_ed25519

# SSH config file — shortcuts for servers you use often
nano ~/.ssh/config
```

```
# ~/.ssh/config
Host myserver
    HostName 192.168.1.10
    User anand
    Port 22
    IdentityFile ~/.ssh/id_ed25519

# now you just type:
ssh myserver
```

---

## `traceroute` — Follow the Path

```bash
traceroute google.com

# each line = one router hop your packet passed through
#  1  192.168.1.1    1.2ms  1.1ms  1.3ms   ← your router
#  2  10.0.0.1       8.4ms  8.1ms  8.2ms   ← your ISP
#  3  * * *                                ← router ignoring ICMP
#  4  142.250.67.14  14.2ms                ← destination

# * * * just means that router doesn't respond to traceroute
# it doesn't mean the path is broken
```

---

## Real World Scenarios

### App can't connect to database
```bash
ping 192.168.1.20                              # db server alive?
nc -zv 192.168.1.20 5432                       # port 5432 open?
ssh anand@192.168.1.20 "ss -tulnp | grep 5432" # postgres listening?
```

### Website is down
```bash
ping myapp.com                  # reachable?
dig myapp.com                   # DNS resolving to right IP?
curl -I https://myapp.com       # HTTP responding?
curl -v https://myapp.com       # full details if needed
```

### Can't SSH into server
```bash
ping 192.168.1.10               # is it alive?
nc -zv 192.168.1.10 22          # is port 22 open?
# ping works, port 22 closed → SSH service down or firewall blocking
```

---

## Scripts I Wrote Today

### `netcheck.sh`
Full network diagnostic tool — takes a hostname or IP as argument,
runs ping, DNS lookup, HTTP check, port checks for 22/80/443,
traceroute hop count, and prints a clean pass/fail summary.
Saves results to a dated log file.

---

## Things That Tripped Me Up

- `ping google.com` working doesn't mean your app can reach google.
  Apps can be blocked by firewall rules that allow ICMP but block TCP.
  Always check the actual port your app uses.
- `* * *` in traceroute doesn't mean it's broken — most routers
  silently drop ICMP packets but still forward your real traffic.
- DNS caching — if you change a DNS record it doesn't update
  immediately everywhere. TTL on the record controls how long
  it's cached. Use `dig +short` to check what's actually resolving.
- `ss -tulnp` needs sudo on some systems to show process names.
  Without sudo it shows the port but not which app owns it.
- SSH key permissions are strict on purpose — if your private key
  is readable by others SSH refuses to use it entirely.

---

## Mac vs Linux Differences

| Task | Linux | Mac |
|------|-------|-----|
| See interfaces | `ip addr` | `ifconfig` |
| Routing table | `ip route` | `netstat -rn` |
| DNS servers | `cat /etc/resolv.conf` | `scutil --dns` |
| Ping count | `ping -c 4` | `ping -c 4` (same) |
| Traceroute | `traceroute` | `traceroute` (same) |
| Port check | `nc -zv host port` | `nc -zv host port` (same) |

---
