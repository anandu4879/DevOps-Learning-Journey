#!/bin/bash
# docker-compose-production-setup.sh
# Complete production multi-container system

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_done()  { echo -e "${GREEN}[✓]${NC}    $1"; }
section()   { echo -e "\n${BLUE}=== $1 ===${NC}\n"; }

# ============================================
# PRODUCTION MULTI-CONTAINER SYSTEM
# ============================================

section "Setup: Create Project"

PROJECT_DIR="/tmp/docker-production-system"
rm -rf "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

log_done "Project directory created"

# ============================================

section "Step 1: Create Flask Application"

cat > app.py << 'APPEOF'
#!/usr/bin/env python3
"""
Production Multi-Container Application
- Web: Flask
- Database: PostgreSQL
- Cache: Redis
"""

from flask import Flask, jsonify
import psycopg2
import redis
import os
import logging
from datetime import datetime

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_db():
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST', 'db'),
            database=os.getenv('DB_NAME', 'production'),
            user=os.getenv('DB_USER', 'postgres'),
            password=os.getenv('DB_PASSWORD', 'postgres'),
            port=os.getenv('DB_PORT', '5432')
        )
        return conn
    except Exception as e:
        logger.error(f"DB error: {e}")
        return None

def get_cache():
    try:
        r = redis.Redis(
            host=os.getenv('CACHE_HOST', 'cache'),
            port=int(os.getenv('CACHE_PORT', '6379')),
            decode_responses=True
        )
        r.ping()
        return r
    except Exception as e:
        logger.error(f"Cache error: {e}")
        return None

@app.route('/')
def home():
    logger.info("Homepage visited")
    return {
        'status': 'running',
        'message': 'Production Multi-Container App',
        'timestamp': str(datetime.now()),
        'components': ['web', 'database', 'cache']
    }

@app.route('/health')
def health():
    db = get_db()
    cache = get_cache()
    
    return {
        'app': 'healthy',
        'database': 'healthy' if db else 'unhealthy',
        'cache': 'healthy' if cache else 'unhealthy'
    }

@app.route('/data')
def data():
    db = get_db()
    if not db:
        return {'error': 'Database unavailable'}, 503
    
    try:
        cursor = db.cursor()
        cursor.execute("SELECT version();")
        version = cursor.fetchone()[0]
        cursor.close()
        db.close()
        return {'database': 'connected', 'version': version[:50]}
    except Exception as e:
        return {'error': str(e)}, 500

@app.route('/cache')
def cache_test():
    cache = get_cache()
    if not cache:
        return {'error': 'Cache unavailable'}, 503
    
    try:
        cache.set('test', 'hello cache', ex=60)
        value = cache.get('test')
        return {'cache': 'working', 'value': value}
    except Exception as e:
        return {'error': str(e)}, 500

if __name__ == '__main__':
    logger.info("Starting production app")
    app.run(host='0.0.0.0', port=5000, debug=False)
APPEOF

log_done "Flask application created"

# ============================================

section "Step 2: Create Dependencies"

cat > requirements.txt << 'DEPSEOF'
Flask==2.3.0
gunicorn==20.1.0
psycopg2-binary==2.9.6
redis==4.5.4
requests==2.31.0
DEPSEOF

log_done "Requirements file created"

# ============================================

section "Step 3: Create Production Dockerfile"

cat > Dockerfile << 'DOCKEREOF'
FROM python:3.10-slim as builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.10-slim

RUN useradd -m -u 1000 appuser

WORKDIR /app

COPY --from=builder /root/.local /home/appuser/.local
COPY app.py .

USER appuser
ENV PATH=/home/appuser/.local/bin:$PATH

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
    CMD python -c "import requests; requests.get('http://localhost:5000/health')" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
DOCKEREOF

log_done "Production Dockerfile created"

# ============================================

section "Step 4: Create Docker Compose File"

cat > docker-compose.yml << 'COMPOSEEOF'
version: '3.8'

services:
  web:
    build: .
    container_name: app-web
    ports:
      - "5000:5000"
    environment:
      - DB_HOST=db
      - DB_PORT=5432
      - DB_USER=postgres
      - DB_PASSWORD=postgres_secret
      - DB_NAME=production_db
      - CACHE_HOST=cache
      - CACHE_PORT=6379
    depends_on:
      db:
        condition: service_healthy
    networks:
      - app-network
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  db:
    image: postgres:15-alpine
    container_name: app-db
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres_secret
      - POSTGRES_DB=production_db
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  cache:
    image: redis:7-alpine
    container_name: app-cache
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - app-network
    restart: unless-stopped
    command: redis-server --appendonly yes

volumes:
  postgres-data:
  redis-data:

networks:
  app-network:
    driver: bridge
COMPOSEEOF

log_done "Docker Compose file created"

# ============================================

section "Step 5: Build and Start Services"

log_info "Building image..."
docker compose build

log_done "Image built"

log_info "Starting services..."
docker compose up -d

log_done "Services started"

# ============================================

section "Step 6: Wait for Services"

log_info "Waiting for services to be healthy..."
sleep 15

log_done "Services should be ready"

# ============================================

section "Step 7: Verify Services"

echo ""
log_info "Service status:"
docker compose ps

echo ""
log_info "Testing endpoints..."

sleep 2

echo ""
echo "Homepage:"
curl -s http://localhost:5000/ | python3 -m json.tool | head -15

echo ""
echo "Health check:"
curl -s http://localhost:5000/health | python3 -m json.tool

echo ""
echo "Database connection:"
curl -s http://localhost:5000/data | python3 -m json.tool

echo ""
echo "Cache test:"
curl -s http://localhost:5000/cache | python3 -m json.tool

# ============================================

section "Step 8: View Logs"

echo ""
log_info "Recent web logs:"
docker compose logs -n 3 web

echo ""
log_info "Recent database logs:"
docker compose logs -n 3 db

# ============================================

section "Complete Production System Ready"

echo ""
echo -e "${GREEN}✓ Web: http://localhost:5000${NC}"
echo -e "${GREEN}✓ Database: localhost:5432${NC}"
echo -e "${GREEN}✓ Cache: localhost:6379${NC}"
echo ""
echo "All services connected and healthy!"
echo ""
echo "Useful commands:"
echo "  docker-compose logs -f web      # Follow web logs"
echo "  docker-compose ps               # Service status"
echo "  docker-compose stop             # Stop all"
echo "  docker-compose down             # Stop and remove"
echo "  docker-compose exec db psql ... # Access database"
echo "  docker-compose exec cache redis-cli  # Access cache"
echo ""