# KodeKloud / xFusionCorp DevOps Labs - Personal Reference Guide

## Overview

This README contains solutions, concepts, troubleshooting steps, and explanations from multiple KodeKloud/xFusionCorp Apache, Nginx, Reverse Proxy, SSL, Authentication, Firewall, and Linux administration tasks.

---

# 1. Apache + Nginx Reverse Proxy Setup

## Task

- Install Apache
- Configure Apache on port 3001
- Install Nginx
- Configure Nginx on port 8091
- Configure Nginx as reverse proxy to Apache
- Deploy website
- Verify using curl

## Architecture

```text
Client
   |
   v
Nginx :8091
   |
   v
Apache :3001
   |
   v
Website
```

## Apache Configuration

Edit:

```bash
vi /etc/httpd/conf/httpd.conf
```

Change:

```apache
Listen 80
```

to

```apache
Listen 3001
```

Verify:

```bash
httpd -t
```

---

## Nginx Configuration

Edit:

```bash
vi /etc/nginx/nginx.conf
```

Change:

```nginx
listen 80;
```

to

```nginx
listen 8091;
```

Reverse proxy:

```nginx
location / {
    proxy_pass http://localhost:3001;
}
```

Validate:

```bash
nginx -t
```

Restart:

```bash
systemctl restart nginx
systemctl restart httpd
```

Test:

```bash
curl http://localhost:8091
```

---

# 2. Apache Basic Authentication (.htaccess)

## Task

Protect:

```text
/var/www/html/itadmin
```

Using:

```text
Username: siva
Password: YchZHRcLkL
```

---

## Create Directory

```bash
mkdir -p /var/www/html/itadmin
```

---

## Create Password File

```bash
htpasswd -cb /etc/httpd/.htpasswd siva YchZHRcLkL
```

---

## Create .htaccess

```bash
vi /var/www/html/itadmin/.htaccess
```

Content:

```apache
AuthType Basic
AuthName "Restricted Area"
AuthUserFile /etc/httpd/.htpasswd
Require valid-user
```

---

## Enable .htaccess

Edit:

```bash
vi /etc/httpd/conf/httpd.conf
```

Find:

```apache
AllowOverride None
```

Change:

```apache
AllowOverride AuthConfig
```

or

```apache
AllowOverride All
```

Restart:

```bash
systemctl restart httpd
```

Test:

```bash
curl http://localhost/itadmin/
```

Expected:

```text
401 Authorization Required
```

---

# 3. Apache Troubleshooting (Port 8088)

## Task

Apache should run on:

```text
Port 8088
```

on all app servers.

---

## Check Apache Status

```bash
systemctl status httpd
```

---

## Verify Port

```bash
grep ^Listen /etc/httpd/conf/httpd.conf
```

Expected:

```apache
Listen 8088
```

---

## Verify Syntax

```bash
httpd -t
```

Expected:

```text
Syntax OK
```

---

## Start Service

```bash
systemctl restart httpd
```

Verify:

```bash
ss -tlnp | grep 8088
```

---

# 4. PAM Authentication (Important Lesson)

## What We Learned

Many KodeKloud tasks say:

```text
Use PAM Authentication
Do not use htpasswd
Authenticate Linux users
```

BUT...

The correct solution was NOT:

```apache
AuthBasicProvider PAM
```

Instead it was:

```apache
AuthBasicProvider external
AuthExternal pwauth
```

---

## Install Required Packages

```bash
yum --enablerepo=epel -y install mod_authnz_external pwauth
```

---

## Configure Apache

Edit:

```bash
vi /etc/httpd/conf.d/authnz_external.conf
```

Add:

```apache
<Directory /var/www/html/protected>

AuthType Basic

AuthName "PAM Authentication"

AuthBasicProvider external

AuthExternal pwauth

require valid-user

</Directory>
```

---

## Create Protected Directory

```bash
mkdir -p /var/www/html/protected
```

Create test page:

```bash
echo "This is KodeKloud Protected Directory" > /var/www/html/protected/index.html
```

---

## Start Apache

```bash
systemctl restart httpd
```

---

## Test

```bash
curl -u anita:GyQkFRVNr3 http://localhost/protected/
```

Expected:

```text
This is KodeKloud Protected Directory
```

---

## Major Lesson

When task says:

```text
PAM Authentication
```

Always check whether KodeKloud expects:

```apache
AuthBasicProvider external
AuthExternal pwauth
```

instead of:

```apache
AuthBasicProvider PAM
```

---

# 5. Nginx SSL HTTPS Deployment

## Task

- Install nginx
- Configure SSL
- Deploy certificate
- Serve Welcome page

---

## Install Nginx

```bash
yum install -y nginx
```

---

## Create SSL Directory

```bash
mkdir -p /etc/nginx/ssl
```

Move files:

```bash
mv /tmp/nautilus.crt /etc/nginx/ssl/
mv /tmp/nautilus.key /etc/nginx/ssl/
```

---

## Create Website

```bash
echo "Welcome!" > /usr/share/nginx/html/index.html
```

---

## Configure HTTPS

Edit:

```bash
vi /etc/nginx/nginx.conf
```

Add:

```nginx
server {
    listen 443 ssl;

    ssl_certificate /etc/nginx/ssl/nautilus.crt;
    ssl_certificate_key /etc/nginx/ssl/nautilus.key;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
```

---

## Validate

```bash
nginx -t
```

---

## Start Nginx

```bash
systemctl enable nginx
systemctl restart nginx
```

---

## Test

```bash
curl -k https://localhost
```

Expected:

```text
Welcome!
```

---

# 6. Useful Apache Commands

## Status

```bash
systemctl status httpd
```

## Restart

```bash
systemctl restart httpd
```

## Validate Config

```bash
httpd -t
```

## Logs

```bash
tail -f /var/log/httpd/error_log
```

## Listening Ports

```bash
ss -tlnp
```

---

# 7. Useful Nginx Commands

## Validate

```bash
nginx -t
```

## Restart

```bash
systemctl restart nginx
```

## Status

```bash
systemctl status nginx
```

## Logs

```bash
tail -f /var/log/nginx/error.log
```

---

# 8. Common Troubleshooting Workflow

## Service Won't Start

Check:

```bash
systemctl status SERVICE
```

Then:

```bash
journalctl -xeu SERVICE
```

---

## Apache Config Error

```bash
httpd -t
```

---

## Nginx Config Error

```bash
nginx -t
```

---

## Port Already In Use

```bash
ss -tlnp
```

or

```bash
lsof -i :PORT
```

---

## Firewall Issues

Check:

```bash
iptables -L -n
```

or

```bash
firewall-cmd --list-all
```

---

# DevOps Lessons Learned

1. Never blindly memorize commands.
2. Understand traffic flow.
3. Always validate config before restart.
4. Read logs first.
5. Use curl for verification.
6. Learn what each directive actually does.
7. Troubleshooting skill is more important than memorization.
8. KodeKloud tasks often have hidden tricks—read requirements carefully.
9. Authentication tasks may use pwauth instead of mod_authnz_pam.
10. Always test exactly as task validator will test.

---

# Quick Validation Checklist

## Apache

```bash
httpd -t
systemctl status httpd
ss -tlnp | grep httpd
```

## Nginx

```bash
nginx -t
systemctl status nginx
ss -tlnp | grep nginx
```

## Authentication

```bash
curl -u user:password URL
```

## SSL

```bash
curl -k https://HOST
```

## Reverse Proxy

```bash
curl http://HOST:PORT
```

---

Happy Learning 🚀
Linux + Networking + Apache + Nginx + Troubleshooting = Core DevOps Skills