# Docker Learning Notes - KodeKloud Tasks

## 📚 Overview

These notes summarize several Docker tasks I completed while practicing DevOps on KodeKloud. The goal is not just to memorize commands, but to understand **why** each command is used and **how** Docker works behind the scenes.

---

# 1. Creating a Docker Network

## Task

* Create a Docker network named **ecommerce**
* Use **macvlan** driver
* Subnet: **192.168.0.0/24**
* IP Range: **192.168.0.0/24**

## Command

```bash
docker network create \
-d macvlan \
--subnet=192.168.0.0/24 \
--ip-range=192.168.0.0/24 \
-o parent=eth0 \
ecommerce
```

> Replace `eth0` with the actual network interface if necessary.

---

## Why do we create Docker networks?

Docker networks allow containers to communicate securely.

Instead of putting every container on Docker's default network, we create dedicated networks for:

* Application isolation
* Security
* Easy container-to-container communication
* Custom IP addressing

Example:

```
ecommerce
│
├── frontend
├── backend
└── database
```

Only containers connected to this network can communicate.

---

## Why use macvlan?

Normally Docker gives containers private IPs like:

```
172.17.x.x
```

With **macvlan**, containers receive IP addresses from the physical LAN.

Example:

```
Host Network

192.168.0.10
192.168.0.11
192.168.0.12
```

Each container behaves like a separate physical machine.

---

# 2. Running an Nginx Container with a Volume

## Task

* Pull nginx image
* Create container named **apps**
* Mount

```
Host:
/opt/sysops

Container:
/usr/src
```

* Copy sample.txt into host directory

---

## Commands

```bash
docker pull nginx

cp /tmp/sample.txt /opt/sysops/

docker run -d \
--name apps \
-v /opt/sysops:/usr/src \
nginx
```

---

## Why mount a volume?

Containers are temporary.

If a container is deleted, its internal filesystem is lost.

Volumes store data outside the container.

```
Host
/opt/sysops
      ▲
      │
      ▼
Container
/usr/src
```

Files written inside the container immediately appear on the host.

This is why databases always use volumes.

---

# 3. Running Nginx with Port Mapping

## Task

* Pull nginx:alpine
* Create container named media
* Map host port 8084 to container port 80

---

## Command

```bash
docker pull nginx:alpine

docker run -d \
--name media \
-p 8084:80 \
nginx:alpine
```

---

## Why map ports?

The container listens on port 80.

Outside users cannot access it directly.

Port mapping connects:

```
Host Port 8084
        │
        ▼
Container Port 80
```

Users visit:

```
http://server:8084
```

Docker forwards traffic to Apache/Nginx inside the container.

---

## Why use nginx:alpine?

The Alpine version is:

* Smaller
* Faster to download
* Uses less disk space
* Commonly used in production

---

# 4. Transferring Docker Images Between Servers

## Task

Move image

```
cluster:datacenter
```

from App Server 1 to App Server 3.

---

## Commands

### On App Server 1

```bash
docker save -o /tmp/cluster.tar cluster:datacenter

scp /tmp/cluster.tar user@stapp03:/tmp/
```

### On App Server 3

```bash
docker load -i /tmp/cluster.tar
```

---

## Why use docker save?

Docker images cannot simply be copied.

```
Image
   │
docker save
   │
cluster.tar
```

The tar archive contains:

* Image layers
* Metadata
* Tags

---

## Why docker load?

Imports the archive back into Docker.

```
cluster.tar

↓

docker load

↓

cluster:datacenter
```

---

## Difference

| Command       | Purpose                     |
| ------------- | --------------------------- |
| docker save   | Export image                |
| docker load   | Import image                |
| docker export | Export container filesystem |
| docker import | Import exported filesystem  |

---

# 5. Hosting a Static Website Using Docker Compose

## Task

Create:

```
/opt/docker/docker-compose.yml
```

Requirements:

* httpd image
* container name httpd
* Host Port 6200
* Container Port 80
* Volume mapping

```
Host
/opt/sysops

↓

Container
/usr/local/apache2/htdocs
```

---

## docker-compose.yml

```yaml
version: "3.8"

services:
  web:
    image: httpd:latest
    container_name: httpd

    ports:
      - "6200:80"

    volumes:
      - /opt/sysops:/usr/local/apache2/htdocs
```

---

## Start

```bash
docker compose up -d
```

---

## Why Docker Compose?

Without Compose:

```bash
docker run ...
```

works fine for one container.

For applications with:

* Web Server
* Database
* Redis
* RabbitMQ

commands become very long.

Compose stores everything inside YAML.

```
docker-compose.yml

↓

docker compose up

↓

Containers created automatically
```

---

## Volume Mapping

```
Host

/opt/sysops

        ▲
        │

Container

/usr/local/apache2/htdocs
```

Apache serves files directly from the host.

No copying required.

---

## Port Mapping

```
Browser

↓

Host:6200

↓

Docker

↓

Container:80
```

---

# Important Docker Concepts

## Image

A blueprint for creating containers.

Examples

```
nginx
ubuntu
mysql
httpd
```

---

## Container

A running instance of an image.

```
Image

↓

Container
```

---

## Volume

Persistent storage.

```
Host

↓

Volume

↓

Container
```

---

## Network

Allows containers to communicate.

Types:

* bridge
* host
* overlay
* macvlan

---

## Port Mapping

```
Host Port

↓

Container Port
```

Example:

```
8084:80
```

---

## Docker Compose

Defines infrastructure as code.

Instead of long docker run commands, everything is described in YAML.

---

# Frequently Used Commands

## Images

```bash
docker images

docker pull nginx

docker rmi nginx
```

---

## Containers

```bash
docker ps

docker ps -a

docker run

docker stop

docker start

docker rm
```

---

## Volumes

```bash
docker volume ls

docker volume create

docker volume rm
```

---

## Networks

```bash
docker network ls

docker network inspect

docker network create
```

---

## Compose

```bash
docker compose up -d

docker compose down

docker compose ps

docker compose logs
```

---

# Key Takeaways

* **Images** are blueprints.
* **Containers** are running instances of images.
* **Volumes** keep data safe even if containers are deleted.
* **Networks** enable secure communication between containers.
* **Port mapping** exposes container services to the outside world.
* **Docker Compose** defines multi-container applications in a reusable YAML file.
* **docker save/load** is used to transfer images between servers.
* **macvlan** allows containers to appear as devices on the physical network.

---

## Learning Outcome

These exercises helped reinforce the following Docker concepts:

* Docker Images
* Docker Containers
* Port Mapping
* Volume Mounting
* Docker Networks
* macvlan Networking
* Docker Compose
* Image Export & Import
* Static Website Hosting with Containers
* Container Lifecycle Management

