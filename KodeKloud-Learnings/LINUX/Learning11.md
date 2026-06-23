# KodeKloud Nautilus DevOps Tasks - Personal Notes

## 1. Nginx Load Balancer Configuration

### Task

Configure Nginx on LBR server to load balance traffic across all app servers.

### Architecture

Client → Nginx Load Balancer → App Servers

### Install Nginx

```bash
yum install -y nginx
```

### Configure Nginx

Edit:

```bash
vi /etc/nginx/nginx.conf
```

```nginx
http {

    upstream backend {
        server stapp01:6200;
        server stapp02:6200;
        server stapp03:6200;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://backend;
        }
    }
}
```

### Validate

```bash
nginx -t
systemctl restart nginx
```

### Verify

```bash
curl http://stlb01
```

### Troubleshooting

Check Apache port:

```bash
ss -tulpn | grep httpd
```

Check backend:

```bash
curl http://stapp01:6200
```

---

# 2. PostgreSQL Database Setup

### Task

Create:

* User: kodekloud_tim
* Password: GyQkFRVNr3
* Database: kodekloud_db4

### Login

```bash
sudo -u postgres psql
```

### Commands

```sql
CREATE USER kodekloud_tim WITH PASSWORD 'GyQkFRVNr3';

CREATE DATABASE kodekloud_db4;

GRANT ALL PRIVILEGES ON DATABASE kodekloud_db4 TO kodekloud_tim;
```

### Verify

```sql
\du
\l
```

---

# 3. MariaDB Database Setup

### Install MariaDB

```bash
yum install -y mariadb-server
```

### Start Service

```bash
systemctl enable mariadb
systemctl start mariadb
```

### Login

```bash
mysql
```

### Create Database

```sql
CREATE DATABASE kodekloud_db2;
```

### Create User

```sql
CREATE USER 'kodekloud_cap'@'localhost'
IDENTIFIED BY 'B4zNgHA7Ya';
```

### Grant Access

```sql
GRANT ALL PRIVILEGES ON kodekloud_db2.*
TO 'kodekloud_cap'@'localhost';

FLUSH PRIVILEGES;
```

---

# 4. MariaDB Automation Script

### Script Location

```bash
/opt/scripts/database.sh
```

### Purpose

* Create DB
* Create User
* Import Dump
* Take Backup

### Make Executable

```bash
chmod +x /opt/scripts/database.sh
```

### Run

```bash
/opt/scripts/database.sh
```

### Backup

```bash
mysqldump kodekloud_db01 > /opt/db_backups/kodekloud_db01.sql
```

---

# 5. Apache Multiple Static Websites

### Task

Serve:

```text
http://localhost:8085/blog/
http://localhost:8085/games/
```

### Install Apache

```bash
yum install -y httpd
```

### Change Port

Edit:

```bash
vi /etc/httpd/conf/httpd.conf
```

```apache
Listen 8085
```

### Create Directories

```bash
mkdir -p /var/www/html/blog
mkdir -p /var/www/html/games
```

### Alias Configuration

File:

```bash
/etc/httpd/conf.d/websites.conf
```

```apache
Alias /blog /var/www/html/blog
Alias /games /var/www/html/games

<Directory /var/www/html/blog>
    Require all granted
</Directory>

<Directory /var/www/html/games>
    Require all granted
</Directory>
```

### Restart

```bash
systemctl restart httpd
```

### Verify

```bash
curl http://localhost:8085/blog/
curl http://localhost:8085/games/
```

---

# 6. Nginx + PHP-FPM (Port 9000)

### Architecture

Nginx → PHP-FPM → PHP Application

### Install

```bash
yum install -y nginx
yum install -y php php-cli php-fpm
```

### Configure PHP-FPM

```bash
vi /etc/php-fpm.d/www.conf
```

```ini
listen = 127.0.0.1:9000
```

### Configure Nginx

```nginx
server {
    listen 8096;

    root /var/www/html;

    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        root           /var/www/html;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
}
```

### Important Troubleshooting

Find socket references:

```bash
grep -R "www.sock" /etc/nginx/
```

Find FastCGI references:

```bash
grep -R "fastcgi_pass" /etc/nginx/
```

---

# 7. Nginx + PHP-FPM (Unix Socket)

### Requirements

```text
Port: 8092
Socket: /var/run/php-fpm/default.sock
```

### Create Directory

```bash
mkdir -p /var/run/php-fpm
```

### Configure PHP-FPM

```ini
listen = /var/run/php-fpm/default.sock

listen.owner = nginx
listen.group = nginx

user = nginx
group = nginx
```

### Configure Nginx

```nginx
location ~ \.php$ {

    include fastcgi_params;

    fastcgi_index index.php;

    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

    fastcgi_pass unix:/var/run/php-fpm/default.sock;
}
```

### Restart

```bash
systemctl restart php-fpm
systemctl restart nginx
```

### Verify Socket

```bash
ls -l /var/run/php-fpm/default.sock
```

---

# DevOps Troubleshooting Mindset

For every task ask:

1. What is the current architecture?
2. What is the desired architecture?
3. Which service is failing?
4. What logs should I check?
5. How do I verify success?

### Common Commands

Check Services

```bash
systemctl status nginx
systemctl status httpd
systemctl status php-fpm
systemctl status mariadb
```

Check Ports

```bash
ss -tulpn
```

Check Logs

```bash
tail -f /var/log/nginx/error.log

tail -f /var/log/httpd/error_log

journalctl -u php-fpm

journalctl -u nginx
```

Check Configuration

```bash
nginx -t

httpd -t
```

Check Connectivity

```bash
curl http://localhost

curl http://localhost:8085

curl http://localhost:8092/index.php
```

---

# Key DevOps Principle

Always think:

```text
Check
  ↓
Create
  ↓
Configure
  ↓
Verify
  ↓
Troubleshoot
```

Never memorize commands without understanding the traffic flow and architecture.
