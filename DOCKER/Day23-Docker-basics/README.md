# Day 23 — Docker Basics & Containerization

Today I learned Docker — how to package an app and all its
dependencies into a container that runs the same everywhere.

"It works on my machine" becomes impossible. Docker makes it work
everywhere.

---

## What Is Docker

Docker packages your app + dependencies into a **container** that
runs the same on:
- Your laptop
- A server
- Cloud (AWS, Google Cloud, Azure)
- Your colleague's computer
- Production

```
Without Docker:
"Works on my machine!"
Deploy → breaks
"Install Python 3.10..."
"No wait, we need 3.9..."
(dependency nightmare)

With Docker:
Package app + Python 3.10 + dependencies
Deploy anywhere
Always works
```

---

## Key Concepts

### Image
A **blueprint** or **template**. Like a Lego instruction set.

```
Dockerfile → build → Image

Image contains:
- Base OS (ubuntu, alpine)
- Runtime (Python, Node.js)
- Dependencies (libraries)
- Your code
```

### Container
A **running instance** of an image.

```
Image = blueprint
Container = running application

Like:
House blueprint → Image
Built house where people live → Container

1 image = many containers
Each container is independent
```

---

## Docker Workflow

```
1. Write Dockerfile (recipe)
        ↓
2. docker build (create image)
        ↓
3. docker run (start container)
        ↓
4. App is running!
```

---

## Basic Commands

```bash
# Pull image from Docker Hub
docker pull ubuntu

# List images
docker images

# Run container (one-off)
docker run hello-world

# Run container (interactive)
docker run -it ubuntu bash

# Run container (background)
docker run -d nginx

# List running containers
docker ps

# List all containers
docker ps -a

# Stop container
docker stop <container-id>

# Remove container
docker rm <container-id>

# View logs
docker logs <container-id>

# View logs (follow real-time)
docker logs -f <container-id>
```

---

## Building Images

### Create a Dockerfile

```dockerfile
# Base image
FROM python:3.10-slim

# Working directory
WORKDIR /app

# Copy files
COPY requirements.txt .

# Install dependencies
RUN pip install -r requirements.txt

# Copy code
COPY app.py .

# Expose port
EXPOSE 5000

# Default command
CMD ["python", "app.py"]
```

### Build Image

```bash
# Build
docker build -t myapp:1.0 .

# Flags:
# -t = tag (name:version)
# . = Dockerfile location

# See image
docker images | grep myapp

# Run container from image
docker run -d -p 5000:5000 myapp:1.0
```

---

## Port Mapping

Map container port to local port.

```bash
docker run -p 8080:80 nginx
       # ↑      ↑
       # local  container

# localhost:8080 → container:80

# Multiple ports
docker run -p 8080:80 -p 8443:443 nginx

# Random port (Docker picks)
docker run -p 80 nginx
docker port <container-id>  # shows which port
```

---

## Container Management

### Names

```bash
# Run with name
docker run -d --name my-web nginx

# Stop by name
docker stop my-web

# Remove by name
docker rm my-web
```

### Environment Variables

```bash
# Pass environment variables
docker run -e DB_HOST=localhost -e DB_PORT=5432 myapp

# In app:
import os
db_host = os.getenv('DB_HOST')
```

### Restart Policy

```bash
docker run -d --restart unless-stopped myapp
# --restart unless-stopped = restart on crash

# Options:
# no (don't restart)
# always (always restart)
# unless-stopped (restart unless explicitly stopped)
# on-failure (restart on failure)
```

### Resource Limits

```bash
docker run \
  --memory=512m \
  --cpus=1 \
  myapp

# Limit to 512MB RAM and 1 CPU
```

---

## Real Scenarios

### Scenario 1 — Web App

```bash
# Build
docker build -t mywebapp:1.0 .

# Run
docker run -d -p 8080:80 mywebapp:1.0

# Visit http://localhost:8080
```

### Scenario 2 — Database

```bash
# PostgreSQL container
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  postgres:15

# Your app connects to localhost:5432
```

### Scenario 3 — Development

```bash
# Interactive Python development
docker run -it python:3.10 bash

# You're in Python environment without installing
```

---

## Dockerfile Best Practices

```dockerfile
# ✓ Use specific versions
FROM python:3.10-slim

# ✓ Multi-stage build (smaller images)
FROM python:3.10 as builder
# ...
FROM python:3.10-slim
COPY --from=builder ...

# ✓ Non-root user (security)
RUN useradd -m appuser
USER appuser

# ✓ Health check
HEALTHCHECK --interval=30s CMD curl http://localhost:5000/health

# ✓ .dockerignore (exclude files)
# avoids copying unnecessary files

# ✓ Production server (gunicorn, not Flask dev server)
CMD ["gunicorn", "app:app"]

# ✓ Minimize layers
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
# (combine RUN commands)
```

---

## Challenges Done

### Challenge 1 — Install Docker
Verified Docker installation, checked version.

### Challenge 2 — Run Containers
Ran hello-world, Ubuntu, nginx.
Mapped ports, viewed logs.

### Challenge 3 — Explore Images
Pulled images, inspected them, searched Docker Hub.

### Challenge 4 — Build Image
Created Dockerfile, built image, ran container.

### Challenge 5 — Container Management
Named containers, managed lifecycle, mapped ports.

---

## Scripts Written

### docker-production-setup.sh
Complete production setup:
- Flask app
- Production Dockerfile (multi-stage)
- Non-root user
- Health check
- Resource limits
- Gunicorn server
- All best practices

---

## Things That Clicked

- Image = blueprint, container = running app
- Same code runs same everywhere (no dependency issues)
- Dockerfile = recipe for image
- docker build = create image from Dockerfile
- docker run = start container from image
- Port mapping = localhost:8080 → container:80
- Non-root user = security
- Health check = monitoring
- Multi-stage = smaller images
- Gunicorn = production web server

---

## Docker vs Traditional

| Item | Traditional | Docker |
|------|-------------|--------|
| Setup | Install everything locally | docker run |
| Dependencies | Hope they match | Guaranteed to match |
| Works locally | Maybe works on server | Always works |
| Scaling | Manual + hard | Easy |
| Environment | Different per server | Identical everywhere |

---

## Image Layers

Each line in Dockerfile = one layer.

```dockerfile
FROM ubuntu           (layer 1)
RUN apt-get update   (layer 2)
RUN pip install X    (layer 3)
COPY app.py          (layer 4)
CMD python app.py    (layer 5)
```

Docker caches layers:
- If layer 1-3 unchanged, reuse them
- Only rebuild 4-5 if they changed
- Fast rebuilds!

---

## Statistics

```
Day 23:
- Concepts: 8 (image, container, Dockerfile, build, run, etc)
- Challenges: 5
- Commands learned: 25+
- Real scenarios: 3
- Production script: 1 complete setup
```
