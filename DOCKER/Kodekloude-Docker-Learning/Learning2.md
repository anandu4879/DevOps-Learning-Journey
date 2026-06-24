# Docker & Container Administration - KodeKloud Practice Notes

## Overview

This document contains solutions, explanations, commands, and concepts learned while working on Docker-related tasks in the Nautilus Project (Stratos Datacenter).

---

# 1. Pull an Image and Create a New Tag

## Task

Pull `busybox:musl` on App Server 2 and create a new tag:

```text
busybox:local
```

## Commands

```bash
docker pull busybox:musl
docker tag busybox:musl busybox:local
```

## Verification

```bash
docker images
```

Expected:

```text
REPOSITORY   TAG
busybox      musl
busybox      local
```

## Concept

Docker tags are aliases pointing to the same image ID.

```bash
docker tag SOURCE_IMAGE:TAG TARGET_IMAGE:TAG
```

Example:

```bash
docker tag busybox:musl busybox:local
```

---

# 2. Allow a User to Run Docker Without Sudo

## Task

User `siva` must run Docker commands without sudo.

## Commands

```bash
sudo usermod -aG docker siva
```

## Verification

```bash
groups siva
```

or

```bash
id siva
```

Expected:

```text
docker
```

should appear in the group list.

## Why?

Docker daemon runs as root.

Members of the docker group can access:

```text
/var/run/docker.sock
```

without sudo.

---

# 3. List Linux Groups

## View All Groups

```bash
cat /etc/group
```

Only group names:

```bash
cut -d: -f1 /etc/group
```

## Check User Groups

```bash
groups username
```

Example:

```bash
groups siva
```

or

```bash
id siva
```

## Check Docker Group

```bash
grep docker /etc/group
```

---

# 4. Create an Image from a Running Container

## Task

Create:

```text
media:devops
```

from container:

```text
ubuntu_latest
```

## Command

```bash
docker commit ubuntu_latest media:devops
```

## Verification

```bash
docker images
```

Expected:

```text
REPOSITORY   TAG
media        devops
```

## Concept

### Container

Running instance of an image.

### Image

Blueprint/template.

### Commit

Saves container changes into a new image.

```bash
docker commit CONTAINER IMAGE:TAG
```

---

# 5. Install Apache Inside a Running Container

## Task

Container:

```text
kkloud
```

Requirements:

* Install apache2
* Listen on port 3000
* Apache running
* Container remains running

---

## Enter Container

```bash
docker exec -it kkloud bash
```

---

## Install Apache

```bash
apt update
apt install apache2 -y
```

---

## Configure Port

### Update ports.conf

```bash
sed -i 's/Listen 80/Listen 3000/' /etc/apache2/ports.conf
```

### Update Virtual Host

```bash
sed -i 's/<VirtualHost \*:80>/<VirtualHost *:3000>/' \
/etc/apache2/sites-available/000-default.conf
```

---

## Start Apache

```bash
service apache2 start
```

or

```bash
apachectl start
```

---

## Verification

```bash
ss -tlnp | grep 3000
```

Expected:

```text
LISTEN *:3000
```

---

## Apache Warning

Warning:

```text
Could not reliably determine the server's fully qualified domain name
```

This is usually harmless.

Optional fix:

```bash
echo "ServerName localhost" >> /etc/apache2/apache2.conf
service apache2 restart
```

---

# 6. Create a Dockerfile with Apache on Port 8088

## Task

Create:

```text
/opt/docker/Dockerfile
```

Requirements:

* Base image ubuntu:24.04
* Install apache2
* Configure Apache on 8088
* Keep default document root

---

## Dockerfile

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y apache2 && \
    sed -i 's/Listen 80/Listen 8088/' /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8088>/' /etc/apache2/sites-available/000-default.conf

EXPOSE 8088

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
```

---

## Build Image

```bash
docker build -t apache-custom .
```

---

## Run Container

```bash
docker run -d -p 8088:8088 apache-custom
```

---

# Common Docker Commands

## Images

```bash
docker images
```

```bash
docker pull nginx
```

```bash
docker rmi IMAGE_ID
```

---

## Containers

### Running Containers

```bash
docker ps
```

### All Containers

```bash
docker ps -a
```

### Start

```bash
docker start CONTAINER
```

### Stop

```bash
docker stop CONTAINER
```

### Restart

```bash
docker restart CONTAINER
```

### Remove

```bash
docker rm CONTAINER
```

---

## Execute Inside Container

```bash
docker exec -it CONTAINER bash
```

Example:

```bash
docker exec -it kkloud bash
```

---

## Logs

```bash
docker logs CONTAINER
```

Follow logs:

```bash
docker logs -f CONTAINER
```

---

## Inspect

```bash
docker inspect CONTAINER
```

---

## Port Mapping

```bash
docker run -p HOST_PORT:CONTAINER_PORT IMAGE
```

Example:

```bash
docker run -p 8080:80 nginx
```

---

# KodeKloud Exam Tips

## Image Tasks

Look for:

```text
docker pull
docker tag
docker commit
docker build
```

---

## Container Tasks

Look for:

```text
docker exec
docker ps
docker inspect
docker logs
```

---

## User Permission Tasks

Most common solution:

```bash
usermod -aG docker USER
```

---

## Apache Tasks

Most common files:

```text
/etc/apache2/ports.conf

/etc/apache2/sites-available/000-default.conf
```

Change both files whenever port changes.

---

# Key Learning Summary

### Docker Pull

Downloads image.

```bash
docker pull image:tag
```

### Docker Tag

Creates another name for image.

```bash
docker tag source target
```

### Docker Commit

Creates image from container.

```bash
docker commit container image:tag
```

### Docker Exec

Access running container.

```bash
docker exec -it container bash
```

### Docker Build

Creates image from Dockerfile.

```bash
docker build -t image .
```

### Docker Group

Allows Docker usage without sudo.

```bash
usermod -aG docker username
```

### Apache Port Change

Always modify:

```text
ports.conf
000-default.conf
```

and restart Apache.

---

## Author

DevOps Learning Journey

Focus Areas:

* Linux Administration
* Docker
* Git
* Kubernetes
* AWS
* KodeKloud Labs
* DevOps Engineering
