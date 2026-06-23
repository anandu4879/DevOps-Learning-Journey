# KodeKloud DevOps Challenges - Learning Notes

## Goal

This document contains the challenges I solved, the commands used, the reasoning behind them, and the troubleshooting approach. The goal is not to memorize commands but to understand the thought process of a DevOps Engineer.

---

# Challenge 1: Apache Security Hardening

## Requirement

* Install Apache (httpd)
* Run Apache on port 6100
* Create a webpage
* Configure security headers:

  * X-XSS-Protection
  * X-Frame-Options
  * X-Content-Type-Options

---

## Install Apache

```bash
yum install -y httpd
```

### Explanation

* yum = package manager
* install = install package
* -y = automatically answer yes
* httpd = Apache package

---

## Change Apache Port

Edit:

```bash
vi /etc/httpd/conf/httpd.conf
```

Find:

```apache
Listen 80
```

Change:

```apache
Listen 6100
```

---

## Create Web Page

```bash
echo "Welcome to the xFusionCorp Industries!" > /var/www/html/index.html
```

---

## Add Security Headers

Edit:

```bash
vi /etc/httpd/conf/httpd.conf
```

Add:

```apache
Header always set X-XSS-Protection "1; mode=block"
Header always set X-Frame-Options "SAMEORIGIN"
Header always set X-Content-Type-Options "nosniff"
```

---

## Start Service

```bash
systemctl enable httpd
systemctl start httpd
```

---

## Verify

```bash
curl http://localhost:6100
```

```bash
curl -I http://localhost:6100
```

Expected headers:

```text
X-XSS-Protection
X-Frame-Options
X-Content-Type-Options
```

---

## Important Learning

Apache hardening often involves:

* Security headers
* SSL/TLS
* Directory listing control
* Server tokens
* File permissions

---

# Challenge 2: Apache Service Troubleshooting

## Requirement

Apache must run on:

```text
Port 8089
```

Document root:

```text
/var/www/html
```

---

## Find Broken Server

From jump host:

```bash
curl http://stapp01:8089/
curl http://stapp02:8089/
curl http://stapp03:8089/
```

---

## Check Service

```bash
systemctl status httpd
```

---

## Validate Configuration

```bash
httpd -t
```

---

## Error Found

```text
DocumentRoot '/var/www/html;' is not a directory
```

Problem:

```apache
DocumentRoot "/var/www/html;"
```

Wrong because of:

```text
;
```

Correct:

```apache
DocumentRoot "/var/www/html"
```

---

## Fix

```bash
vi /etc/httpd/conf/httpd.conf
```

Correct DocumentRoot.

---

## Verify

```bash
httpd -t
```

Expected:

```text
Syntax OK
```

Restart:

```bash
systemctl restart httpd
```

---

## Learning

Always read errors carefully.

Apache usually tells:

* Which line failed
* Which directive failed
* Why it failed

---

# Challenge 3: GPG Encryption and Decryption

## Requirement

Encrypt:

```text
/home/encrypt_me.txt
```

to:

```text
/home/encrypted_me.asc
```

Decrypt:

```text
/home/decrypt_me.asc
```

to:

```text
/home/decrypted_me.txt
```

Passphrase:

```text
kodekloud
```

---

## Import Public Key

```bash
gpg --import /home/public_key.asc
```

---

## Import Private Key

```bash
gpg --import /home/private_key.asc
```

---

## Verify Keys

```bash
gpg --list-keys
```

```bash
gpg --list-secret-keys
```

---

## Encrypt

```bash
gpg --armor \
--output /home/encrypted_me.asc \
--recipient kodekloud@kodekloud.com \
--encrypt /home/encrypt_me.txt
```

---

## Decrypt

```bash
gpg --batch --yes \
--pinentry-mode loopback \
--passphrase kodekloud \
--output /home/decrypted_me.txt \
--decrypt /home/decrypt_me.asc
```

---

## Learning

Public Key:

```text
Encrypt
```

Private Key:

```text
Decrypt
```

Memory Trick:

```text
PUBLIC = LOCK
PRIVATE = UNLOCK
```

---

# Challenge 4: Tomcat Log Rotation

## Requirement

Install Tomcat.

Configure:

```text
monthly
rotate 3
compress
```

---

## Install Tomcat

```bash
yum install -y tomcat
```

---

## Install Logrotate

```bash
yum install -y logrotate
```

---

## Existing Config

```bash
cat /etc/logrotate.d/tomcat.disabled
```

Default:

```conf
weekly
rotate 52
compress
```

---

## Create Config

```bash
vi /etc/logrotate.d/tomcat
```

Content:

```conf
/var/log/tomcat/*.log {
    copytruncate
    monthly
    rotate 3
    compress
    missingok
    create 0644 tomcat tomcat
}
```

---

## Test

```bash
logrotate -d /etc/logrotate.d/tomcat
```

Expected:

```text
monthly (3 rotations)
```

---

## Learning

monthly

```text
Rotate every month
```

rotate 3

```text
Keep 3 archives
```

compress

```text
Store as .gz
```

copytruncate

```text
Rotate logs without stopping Tomcat
```

---

# Challenge 5: Nginx Reverse Proxy Firewall Rules

## Architecture

```text
User
 |
 v
Nginx (8091)
 |
 v
Apache (5004)
```

---

## Requirement

Allow:

```text
8091
```

Block:

```text
5004
```

---

## Install Firewall Packages

```bash
yum install -y iptables
yum install -y iptables-services
```

---

## Start Firewall

```bash
systemctl enable iptables
systemctl start iptables
```

---

## Allow Nginx

```bash
iptables -A INPUT -p tcp --dport 8091 -j ACCEPT
```

Explanation:

* INPUT = incoming traffic
* tcp = TCP protocol
* dport = destination port
* ACCEPT = allow

---

## Block Apache

```bash
iptables -A INPUT -p tcp --dport 5004 -j DROP
```

Explanation:

DROP:

```text
Silently discard traffic
```

---

## Save Rules

```bash
service iptables save
```

or

```bash
iptables-save > /etc/sysconfig/iptables
```

---

## Verify

```bash
iptables -L -n
```

Expected:

```text
ACCEPT tcp dpt:8091
DROP tcp dpt:5004
```

---

## Learning

Public service:

```text
ALLOW
```

Backend service:

```text
BLOCK
```

This is a common production security pattern.

---

# Troubleshooting Checklist

## Service Issues

```bash
systemctl status <service>
```

---

## Configuration Validation

Apache:

```bash
httpd -t
```

---

## View Logs

```bash
journalctl -xeu <service>
```

---

## Check Listening Ports

```bash
ss -tlnp
```

---

## Verify Firewall Rules

```bash
iptables -L -n
```

---

## Verify Web Service

```bash
curl http://localhost:<port>
```

---

# DevOps Golden Rule

Every task should be approached as:

1. Understand Requirement
2. Identify Configuration File
3. Make Change
4. Validate Syntax
5. Restart Service
6. Verify Functionality
7. Troubleshoot Using Logs

