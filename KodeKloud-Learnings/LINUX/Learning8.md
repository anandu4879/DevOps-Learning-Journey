# KodeKloud DevOps Troubleshooting & Configuration Notes

## Overview

This document contains real-world troubleshooting and configuration tasks completed on KodeKloud/Nautilus infrastructure. It focuses on the thought process used by a DevOps engineer rather than simply listing commands.

---

# 1. Apache Redirect Configuration

## Requirement

Configure Apache on App Server 1:

* Listen on port 6300.
* Redirect non-www to www using HTTP 301.
* Redirect `/blog/` to `/news/` using HTTP 302.

## Configure Apache Port

Edit:

```bash
sudo vi /etc/httpd/conf/httpd.conf
```

Change:

```apache
Listen 80
```

to

```apache
Listen 6300
```

## Configure Redirects

```apache
<VirtualHost *:6300>
    ServerName stapp01.stratos.xfusioncorp.com
    Redirect permanent / http://www.stapp01.stratos.xfusioncorp.com:6300/
</VirtualHost>

<VirtualHost *:6300>
    ServerName www.stapp01.stratos.xfusioncorp.com
    Redirect temp /blog/ http://www.stapp01.stratos.xfusioncorp.com:6300/news/
</VirtualHost>
```

## Verify

```bash
sudo httpd -t
sudo systemctl restart httpd

curl -I http://stapp01.stratos.xfusioncorp.com:6300/
curl -I http://www.stapp01.stratos.xfusioncorp.com:6300/blog/
```

---

# 2. SFTP User Configuration

## What is SFTP?

SFTP (SSH File Transfer Protocol) is a secure file transfer mechanism that runs over SSH.

Benefits:

* Encrypted
* Secure
* Can restrict users to file transfer only
* No shell access required

## Requirement

Create:

```text
User: kirsty
Password: dCV3szSGNA
Group: ftp
```

Allow:

```text
SFTP only
```

## Create User

```bash
sudo useradd -G ftp kirsty
echo "kirsty:dCV3szSGNA" | sudo chpasswd
```

## Configure SSH

Edit:

```bash
sudo vi /etc/ssh/sshd_config
```

Add:

```text
Match User kirsty
    PasswordAuthentication yes
    ForceCommand internal-sftp
```

## Validate

```bash
sudo sshd -t
sudo systemctl restart sshd
```

## Verify

```bash
sftp kirsty@localhost
```

Expected:

```text
sftp>
```

---

# 3. Tomcat Installation & ROOT.war Deployment

## Requirement

* Install Tomcat
* Run on port 8086
* Deploy ROOT.war
* Application should work on:

```text
http://stapp02:8086
```

## Install Tomcat

```bash
sudo yum install -y tomcat tomcat-webapps tomcat-admin-webapps
```

## Change Port

Edit:

```bash
sudo vi /etc/tomcat/server.xml
```

Change:

```xml
<Connector port="8080"
```

to

```xml
<Connector port="8086"
```

## Deploy ROOT.war

Copy:

```bash
scp /tmp/ROOT.war user@stapp02:/tmp/
```

Deploy:

```bash
sudo cp /tmp/ROOT.war /var/lib/tomcat/webapps/
```

## Common Issue Encountered

Tomcat default ROOT application already existed.

Existing:

```text
/var/lib/tomcat/webapps/ROOT
```

New deployment:

```text
ROOT.war
```

Tomcat continued serving old ROOT.

## Fix

```bash
sudo systemctl stop tomcat
sudo rm -rf /var/lib/tomcat/webapps/ROOT
sudo systemctl start tomcat
```

Verify:

```bash
curl http://stapp02:8086
```

Expected:

```html
<h2>Welcome to xFusionCorp Industries!</h2>
```

### Lesson Learned

Before deploying:

```bash
ls -l /var/lib/tomcat/webapps/
```

Always inspect existing deployments.

---

# 4. Apache Port Reachability Troubleshooting

## Requirement

Apache not reachable on port 6100.

## Symptoms

From jump host:

```bash
telnet stapp01 6100
```

Output:

```text
No route to host
```

## Investigation

### Step 1

Check service:

```bash
systemctl status httpd
```

Result:

```text
active (running)
```

### Step 2

Check listening port:

```bash
ss -tlnp | grep 6100
```

Result:

```text
*:6100
```

### Step 3

Test locally:

```bash
curl localhost:6100
```

Returned webpage successfully.

## Conclusion

Apache was healthy.

Issue was network access.

## Check iptables

```bash
iptables -L -n
```

Found:

```text
ACCEPT SSH
REJECT ALL
```

No rule allowing:

```text
6100/tcp
```

## Fix

```bash
sudo iptables -I INPUT 5 -p tcp --dport 6100 -j ACCEPT
```

## Verify

From jump host:

```bash
curl http://stapp01:6100
```

Success.

## Key Learning

### Error Mapping

| Error              | Meaning                  |
| ------------------ | ------------------------ |
| Connection Refused | Service not listening    |
| No Route To Host   | Firewall / Network Block |
| Timeout            | Packet dropped           |
| Empty Response     | Application issue        |

---

# 5. iptables Security Hardening

## Requirement

* Install iptables on all app servers.
* Allow port 5004 only from LBR.
* Block everyone else.
* Persist after reboot.

## Install

```bash
sudo yum install -y iptables-services
```

Enable:

```bash
sudo systemctl enable iptables
sudo systemctl start iptables
```

## Find LBR IP

```bash
getent hosts stlb01
```

Example:

```text
10.244.221.120
```

## Allow LBR

```bash
sudo iptables -I INPUT 1 -p tcp -s 10.244.221.120 --dport 5004 -j ACCEPT
```

## Initial Mistake

Rules looked like:

```text
1 ACCEPT LBR
...
6 REJECT ALL
7 DROP 5004
```

Problem:

```text
REJECT ALL
```

executed before:

```text
DROP 5004
```

Therefore DROP never matched.

## Correct Rule Order

```text
1 ACCEPT LBR
2 DROP 5004
3 Other Rules
...
REJECT ALL
```

## Fix

Delete incorrect rule:

```bash
sudo iptables -D INPUT 7
```

Insert correctly:

```bash
sudo iptables -I INPUT 2 -p tcp --dport 5004 -j DROP
```

Verify:

```bash
iptables -L -n --line-numbers
```

Expected:

```text
1 ACCEPT tcp -- 10.244.221.120 tcp dpt:5004
2 DROP   tcp -- 0.0.0.0/0 tcp dpt:5004
```

## Save Rules

```bash
sudo service iptables save
```

or

```bash
sudo iptables-save > /etc/sysconfig/iptables
```

---

# DevOps Troubleshooting Workflow

Whenever something is broken:

```text
1. Reproduce issue
2. Check service status
3. Check listening port
4. Test locally
5. Check firewall
6. Check SELinux
7. Check logs
8. Apply minimum fix
9. Verify from client
10. Persist configuration
```

## Golden Rule

Never immediately change configurations blindly.

Always follow:

```text
Observe
↓
Verify
↓
Isolate
↓
Fix
↓
Validate
```

That mindset is what separates a DevOps engineer from someone who only memorizes commands.
