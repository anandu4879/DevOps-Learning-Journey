# Day 24 — Docker Deep Dive: Volumes, Networks & Compose

Today I learned how to build real production systems:
- Store data safely (volumes)
- Make containers talk to each other (networks)
- Run entire systems together (Docker Compose)

Yesterday: one container.
Today: containers working as a team.

---

## Problem: Real Apps Need Multiple Containers

Day 23: Single container (just your app)

Reality:
```
App needs:
- Web server (Flask, Node.js)
- Database (PostgreSQL)
- Cache (Redis)
- Message queue (RabbitMQ)

That's 4 containers that must:
1. Start in order
2. Talk to each other
3. Persist data
4. Work as one system
```

---

## Part 1: Volumes (Persistent Storage)

### The Problem

Containers are temporary. Container dies → data dies.

```bash
docker run postgres:15
# Database runs in container
# Container crashes
# All data = GONE
```

### Solution: Volumes

Storage that survives container death.

```bash
docker volume create my-data

docker run -v my-data:/data postgres
# Data written to volume
# Container crashes? No problem.
# Volume still exists
```

### In Docker Compose

```yaml
services:
  db:
    image: postgres:15
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
```

---

## Part 2: Networks (Container Communication)

### The Problem

Containers can't find each other by default.

```bash
docker run --name web myapp
docker run --name db postgres

# web tries to connect to db
# connection: localhost:5432
# FAILS! (db not on localhost inside web)
```

### Solution: Docker Networks

```bash
docker network create app-net

docker run --network app-net --name web myapp
docker run --network app-net --name db postgres

# web can reach db!
# Docker DNS: "db" → db container
```

### In Docker Compose

```yaml
version: '3.8'

services:
  web:
    image: myapp
    networks:
      - app-network

  db:
    image: postgres
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

---

## Part 3: Docker Compose

### Manual Way (Don't Do This)

```bash
docker network create app
docker volume create data
docker run -d --name db --network app -v data:/data postgres
docker run -d --name cache --network app redis
docker run -d --name web --network app -p 5000:5000 myapp
```

5 commands, order matters, easy to mess up.

### Docker Compose Way (Do This)

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      retries: 5

  cache:
    image: redis:7

volumes:
  db-data:
```

**Start everything:**
```bash
docker-compose up -d

# Docker:
# 1. Creates network
# 2. Creates volumes
# 3. Starts services in order
# 4. Connects them all
# Everything works!
```

---

## Docker Compose Commands

```bash
# Start
docker-compose up              # foreground
docker-compose up -d           # background

# Stop
docker-compose stop            # graceful
docker-compose down            # stop and remove

# View
docker-compose ps              # status
docker-compose logs            # see logs
docker-compose logs -f web     # follow web logs

# Execute
docker-compose exec db psql    # run in container

# Manage
docker-compose build           # rebuild images
docker-compose pull            # pull new images
```

---

## Docker Compose File Structure

```yaml
version: '3.8'               # version (use 3.8+)

services:                    # containers
  web:
    image: myapp:1.0        # existing image
    # OR
    build: .                # build from Dockerfile
    
    ports:
      - "8080:80"           # port mapping: local:container
    
    environment:            # environment variables
      - DB_HOST=db
      - DB_PORT=5432
    
    volumes:
      - ./app:/app          # bind mount (development)
      - db-data:/data       # named volume (persistent)
    
    depends_on:             # startup order
      - db
    
    networks:
      - app-network
    
    restart: unless-stopped # restart policy
    
    healthcheck:
      test: ["CMD", "curl", "http://localhost"]
      interval: 10s
      retries: 3

  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:                     # named volumes
  db-data:

networks:                    # networks
  app-network:
    driver: bridge
```

---

## Real Scenarios

### Web + Database

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=myapp
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      retries: 5

volumes:
  db-data:
```

### Full Stack (Web + DB + Cache)

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    depends_on:
      db:
        condition: service_healthy
    environment:
      - DB_HOST=db
      - CACHE_HOST=cache

  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]

  cache:
    image: redis:7

volumes:
  db-data:
```

### Development

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - ./src:/app/src      # hot reload!
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development

  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=dev
```

---

## Challenges Done

### Challenge 1 — Volumes
Created volumes, ran containers with persistent storage,
verified data survives container deletion.

### Challenge 2 — Networks
Created network, ran containers on it,
tested container-to-container communication.

### Challenge 3 — Docker Compose
Created compose file, started multi-container app,
tested all services working together.

---

## Scripts Written

### docker-compose-production.sh
Complete production system:
- Flask web app
- PostgreSQL database
- Redis cache
- All connected
- All healthy
- Production-ready

---

## Things That Clicked

- Volumes = persistent storage that survives container death
- Networks = containers communicate by service name (DNS)
- Docker Compose = define multi-container apps in one YAML file
- `depends_on` = control startup order
- `healthcheck` = ensure service is actually ready
- Named volumes = persistent data
- Services on same compose network = automatic DNS resolution
- One `docker-compose.yml` = entire system defined

---

## Volumes vs Bind Mounts

| Type | Use | Managed By | Persistence |
|------|-----|-----------|-------------|
| Named volume | Production data | Docker | Persistent |
| Bind mount | Development | You | Persistent |
| Anonymous volume | Temporary | Docker | Until container removed |

---

## Common Issues & Solutions

```
Issue: Container can't reach another container
Solution: Add both to same network in compose

Issue: Data lost when container crashes
Solution: Use volumes to mount persistent storage

Issue: Port conflict (port already in use)
Solution: Change port mapping in docker-compose.yml

Issue: Don't know why service won't start
Solution: docker-compose logs service-name

Issue: Database not ready when app starts
Solution: Use depends_on with healthcheck

Issue: Changes to code don't reflect
Solution: Use bind mount for development
```

---

## Debugging Docker Compose

```bash
# View status
docker-compose ps

# View logs
docker-compose logs              # all services
docker-compose logs -f web       # follow web
docker-compose logs --tail 20    # last 20 lines

# Execute commands
docker-compose exec db psql -U postgres

# Check resource usage
docker stats

# Inspect services
docker-compose config            # merged config
docker inspect <container-name>  # detailed info
```

---

## Production Checklist

```bash
☐ Define services in docker-compose.yml
☐ Set healthchecks for each service
☐ Use named volumes for data
☐ Set restart: unless-stopped
☐ Configure logging (max-size, max-file)
☐ Set resource limits (optional)
☐ Use environment files for secrets
☐ Test: docker-compose up -d
☐ Test: curl all endpoints
☐ Test: docker-compose logs
☐ Test: stop/start (data persists)
☐ Document how to run locally
☐ Document how to run in production
```

---

## Statistics

```
Day 24:
- Concepts: 3 (volumes, networks, compose)
- Challenges: 3
- Real scenarios: 3
- Commands learned: 20+
- Production system: complete
```

---
