# DevOps Learning Notes - Firewalld, Reverse Proxy, DNS & Mail Server Setup

## Date

June 2026

---

# 1. DNS Resolution Fix

## Task

App Server 2 had DNS resolution issues. We needed to add Google Public DNS servers.

## Configuration

File:

```bash
/etc/resolv.conf
```

Add:

```text
nameserver 8.8.8.8
nameserver 8.8.4.4
```

## Why?

When an application tries to access:

```text
google.com
```

It needs a DNS server to convert the domain name into an IP address.

Google Public DNS:

```text
8.8.8.8
8.8.4.4
```

provides this service.

## Verification

```bash
nslookup google.com
```

---

# 2. Firewalld and Reverse Proxy Architecture

## Task

Configure firewalld on App Server 2.

Requirements:

* Allow port 80
* Block port 8085
* Use public zone
* Make rules permanent
* Ensure Apache and Nginx are running

---

## Commands

Allow Nginx:

```bash
firewall-cmd --permanent --zone=public --add-port=80/tcp
```

Block Apache:

```bash
firewall-cmd --permanent --zone=public --remove-port=8085/tcp
```

Reload:

```bash
firewall-cmd --reload
```

---

## Architecture

```text
Internet
   |
   v
Nginx (80)
   |
   v
Apache (8085)
```

---

## What is a Reverse Proxy?

Think of a hotel.

```text
Guest -> Reception -> Employee
```

In web servers:

```text
User -> Nginx -> Apache
```

Nginx receives requests and forwards them to Apache.

---

## Why Block Port 8085?

We want:

```text
Internet -> Nginx -> Apache
```

Not:

```text
Internet -> Apache
```

Apache is an internal service.

Nginx is the public entry point.

---

## Troubleshooting Nginx

Error:

```text
bind() to 0.0.0.0:80 failed
```

Meaning:

Another process is already using port 80.

Check:

```bash
ss -tulpn | grep :80
```

---

# 3. Mail Server Setup (Postfix + Dovecot)

## Goal

Create:

```text
john@stratos.xfusioncorp.com
```

Password:

```text
BruCStnMT5
```

Mail Directory:

```text
/home/john/Maildir
```

---

# Components

## Postfix

Role:

```text
Mail Transfer Agent (MTA)
```

Responsibilities:

* Receive email
* Deliver email
* Store email

Think:

```text
Postfix = Postman
```

---

## Dovecot

Role:

```text
IMAP / POP3 Server
```

Responsibilities:

* Allow users to read email

Think:

```text
Dovecot = Mailbox Reader
```

---

# User Creation

```bash
useradd john
echo "john:BruCStnMT5" | chpasswd
```

---

# Configure Postfix

File:

```bash
/etc/postfix/main.cf
```

Add:

```ini
myhostname = stmail01.stratos.xfusioncorp.com
mydomain = stratos.xfusioncorp.com
myorigin = $mydomain
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
home_mailbox = Maildir/
```

Restart:

```bash
systemctl restart postfix
```

---

# Understanding Postfix Configuration

## myhostname

```ini
myhostname = stmail01.stratos.xfusioncorp.com
```

Server identity.

Example:

```text
Hello, I am stmail01.stratos.xfusioncorp.com
```

---

## mydomain

```ini
mydomain = stratos.xfusioncorp.com
```

Mail domain owned by the server.

Example:

```text
john@stratos.xfusioncorp.com
```

---

## myorigin

```ini
myorigin = $mydomain
```

Converts local mail:

```text
john
```

to:

```text
john@stratos.xfusioncorp.com
```

---

## mydestination

```ini
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
```

Most important setting.

Tells Postfix:

```text
These domains belong to me.
```

Without this setting:

```text
john@stratos.xfusioncorp.com
```

is not treated as a local mailbox.

Mail delivery fails.

---

## home_mailbox

```ini
home_mailbox = Maildir/
```

Store email in:

```text
/home/john/Maildir
```

instead of:

```text
/var/mail/john
```

---

# Create Maildir

```bash
mkdir -p /home/john/Maildir/{cur,new,tmp}
chown -R john:john /home/john/Maildir
```

Structure:

```text
Maildir
├── cur
├── new
└── tmp
```

---

# Configure Dovecot

File:

```bash
/etc/dovecot/conf.d/10-mail.conf
```

Set:

```ini
mail_location = maildir:~/Maildir
```

Restart:

```bash
systemctl restart dovecot
```

---

# Mail Flow

```text
Internet
   |
   v
Postfix
   |
   v
/home/john/Maildir
   |
   v
Dovecot
   |
   v
Email Client
```

---

# Why Task Initially Failed

Mail arrived for:

```text
john@stratos.xfusioncorp.com
```

Postfix asked:

```text
Do I own stratos.xfusioncorp.com?
```

Answer:

```text
No
```

because mydestination and domain configuration were missing.

After adding:

```ini
mydomain = stratos.xfusioncorp.com
mydestination = ..., $mydomain
```

Postfix understood:

```text
Yes, this is my domain.
```

and delivered the mail successfully.

---

# DevOps Troubleshooting Mindset

When something fails, ask:

## Is the service running?

```bash
systemctl status postfix
systemctl status dovecot
systemctl status nginx
```

---

## Is the port listening?

```bash
ss -tulpn
```

---

## Is the firewall blocking traffic?

```bash
firewall-cmd --list-all
```

---

## Does the application know where to store data?

Examples:

```bash
postconf home_mailbox
doveconf | grep mail_location
```

---

## Check logs

```bash
journalctl -u postfix
journalctl -u dovecot
journalctl -u nginx
```

---

# Key Takeaways

* DNS converts names to IP addresses.
* Firewalld controls network access.
* Nginx acts as a reverse proxy.
* Apache serves backend content.
* Postfix receives and delivers mail.
* Dovecot allows users to read mail.
* Maildir stores emails as files.
* mydestination tells Postfix which domains it owns.
* Always troubleshoot using services, ports, firewall, configuration, and logs.
