# Day 20 — Firewalls & Network Security

Today was about protecting servers from unwanted traffic.
A firewall is a bouncer for your network — decides who gets in,
who gets blocked, and logs suspicious activity.

---

## What Is a Firewall

A firewall controls network traffic based on rules you define.

```
Without firewall:
ANYONE tries to connect
Hackers, bots, attacks
All reach your server

With firewall:
"Who are you?"
"What port?"
"Are you allowed?"
Only legit traffic gets through
```

---

## How Firewalls Work

Three concepts:

1. **Policies** — default behavior
   - INPUT: block by default or allow?
   - OUTPUT: allow outgoing?
   - FORWARD: forward traffic?

2. **Rules** — exceptions to policy
   - Allow SSH
   - Allow HTTP/HTTPS
   - Block everything else

3. **Chains** — where rules apply
   - INPUT: incoming traffic
   - OUTPUT: outgoing traffic
   - FORWARD: traffic passing through

---

## UFW (Uncomplicated Firewall)

Simple firewall for Linux.

```bash
# check status
sudo ufw status

# enable
sudo ufw enable

# disable
sudo ufw disable
```

### Allow/Deny

```bash
# allow SSH
sudo ufw allow 22
sudo ufw allow ssh

# allow HTTP and HTTPS
sudo ufw allow 80
sudo ufw allow 443

# allow from specific IP
sudo ufw allow from 192.168.1.100 to any port 22

# deny a port
sudo ufw deny 23

# rate limit (prevent brute force)
sudo ufw limit ssh

# delete a rule
sudo ufw delete allow 23

# reset (remove all rules)
sudo ufw reset
```

### Policies

```bash
# default policy
sudo ufw default deny incoming      # block by default
sudo ufw default allow outgoing     # allow going out

# see status
sudo ufw status verbose
```

### Logging

```bash
# enable logging
sudo ufw logging on

# view logs
sudo tail -f /var/log/ufw.log

# see blocked connections
grep "DPT=" /var/log/ufw.log | head -20
```

---

## iptables (The Powerful Firewall)

iptables is more powerful but complex. UFW uses it under the hood.

### List Rules

```bash
# list all rules
sudo iptables -L -n

# list with line numbers
sudo iptables -L INPUT -n --line-numbers

# list specific chain
sudo iptables -L INPUT -n
```

### Add Rules

```bash
# allow SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# allow established connections
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# set default policy
sudo iptables -P INPUT DROP
```

### Delete Rules

```bash
# by line number
sudo iptables -D INPUT 3

# flush all
sudo iptables -F
```

Important: iptables changes aren't permanent unless saved.

---

## firewalld (Modern Alternative)

RHEL/CentOS use firewalld instead of UFW.

```bash
# check status
sudo firewall-cmd --state

# allow service
sudo firewall-cmd --add-service=ssh

# allow port
sudo firewall-cmd --add-port=8080/tcp

# make permanent
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

# list services
sudo firewall-cmd --get-services
```

---

## Common Ports

```
22    SSH (remote access)
80    HTTP (web)
443   HTTPS (secure web)
3306  MySQL
5432  PostgreSQL
6379  Redis
8080  Common application port
```

---

## Real Scenarios

### Web Server

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable
```

### With Database

```bash
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
# database only from internal network
sudo ufw allow from 192.168.1.0/24 to any port 5432
sudo ufw enable
```

### Protect Against Brute Force

```bash
# limit SSH attempts
sudo ufw limit ssh

# blocks after 6 attempts in 30 seconds
```

### Block Attacker

```bash
# block an IP
sudo ufw deny from 203.0.113.99

# unblock later
sudo ufw delete deny from 203.0.113.99
```

---

## Challenges Done

### Challenge 1 — Basic UFW
Enabled firewall, allowed common ports, tested rules.

### Challenge 2 — Practical Rules
Set default policies, allowed specific networks, enabled logging.

### Challenge 3 — iptables
Listed rules, added rules with line numbers, understood syntax.

### Challenge 4 — firewalld
If on RHEL/CentOS, configured firewalld services and ports.

---

## Scripts Written

### setup-firewall.sh
Complete production firewall configuration with:
- Enable/disable firewall
- Set default policies
- Allow SSH with rate limiting
- Allow HTTP/HTTPS
- Internal network database access
- Logging setup
- Rule summary

### monitor-firewall.sh
Monitor firewall activity:
- Recently blocked connections
- Top blocked IPs
- Connection statistics
- Active rules

---

## Firewall Rules Checklist

Production server should have:

```bash
☐ SSH allowed (with rate limiting)
☐ HTTP allowed (port 80)
☐ HTTPS allowed (port 443)
☐ Database access restricted to internal IPs
☐ Default policy: deny incoming, allow outgoing
☐ Logging enabled
☐ Rules persistent across reboots
☐ Regular monitoring of blocked attempts
☐ Attacker IPs blocked as needed
☐ Documentation of all open ports
```

---

## UFW vs iptables vs firewalld

| Aspect | UFW | iptables | firewalld |
|--------|-----|----------|-----------|
| Ease | Simple | Complex | Medium |
| Power | Medium | Very powerful | Powerful |
| Persistence | Auto | Manual | Auto |
| System | Ubuntu/Debian | Any Linux | RHEL/CentOS |
| Syntax | Natural | Technical | GUI/CLI |

**For most: use UFW**
**For advanced: use iptables**
**For RHEL: use firewalld**

---

## Monitoring Blocked Traffic

```bash
# watch log in real time
sudo tail -f /var/log/ufw.log

# blocked connections
grep "[UFW BLOCK]" /var/log/ufw.log

# blocked IPs (most to least)
grep "[UFW BLOCK]" /var/log/ufw.log | \
  awk '{print $9}' | \
  sort | uniq -c | sort -rn | head -10

# attacks on SSH
grep "DPT=22" /var/log/ufw.log | wc -l
```

---

## Things That Clicked

- Firewall = traffic bouncer, follows rules you make
- Default policy: deny everything, allow what you need
- UFW is simple, iptables is powerful, firewalld is modern
- SSH should be allowed BEFORE enabling firewall (don't lock yourself out!)
- Rate limiting prevents brute force attacks
- Logging shows you who's trying to attack
- Database should only accept from internal network
- Rules must be persistent (survive reboot)
- Common mistake: forgetting to allow SSH then enabling firewall

---

## Security Best Practices

```bash
# ✓ Default policy: deny incoming, allow outgoing
# ✓ Allow only what you need
# ✓ Use rate limiting on SSH
# ✓ Restrict database to internal network only
# ✓ Enable logging
# ✓ Monitor blocked attempts
# ✓ Document all open ports
# ✓ Block attackers as needed
# ✓ Review rules regularly

# ✗ Don't leave everything open
# ✗ Don't forget to allow SSH before enabling
# ✗ Don't disable logging
# ✗ Don't leave default passwords on services
```

---

## Real Production Workflow

```bash
# 1. Plan what ports you need
# - SSH: 22
# - HTTP: 80
# - HTTPS: 443
# - App: 3000
# - Database: 5432 (internal only)

# 2. Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 3. Allow what you need
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 3000
sudo ufw allow from 192.168.1.0/24 to any port 5432

# 4. Enable logging
sudo ufw logging medium

# 5. Enable firewall
sudo ufw enable

# 6. Monitor
tail -f /var/log/ufw.log

# 7. Block attackers as needed
sudo ufw deny from <attacker-ip>
```

---