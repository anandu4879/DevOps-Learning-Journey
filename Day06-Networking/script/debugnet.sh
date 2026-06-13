#!/bin/bash

# Usage: ./debugnet.sh <host> <port>

HOST=$1
PORT=$2

if [ -z "$HOST" ] || [ -z "$PORT" ]; then
    echo "Usage: $0 <host> <port>"
    exit 1
fi

PING_OK=false
DNS_OK=true
PORT_OK=false
HTTP_OK=false

echo "===================================="
echo " Network Debug Tool"
echo " Host: $HOST"
echo " Port: $PORT"
echo "===================================="

# Layer 1 - Ping Check
echo
echo "[Layer 1] Connectivity Check"

if ping -c 2 -W 2 "$HOST" >/dev/null 2>&1; then
    echo "PASS - Host reachable"
    PING_OK=true
else
    echo "FAIL - Host unreachable"
fi

# Layer 4 - DNS Check (only for hostnames)
echo
echo "[Layer 4] DNS Check"

if [[ "$HOST" =~ [a-zA-Z] ]]; then
    RESOLVED_IP=$(dig +short "$HOST" | head -1)

    if [ -n "$RESOLVED_IP" ]; then
        echo "PASS - Resolved to $RESOLVED_IP"
    else
        echo "FAIL - DNS resolution failed"
        DNS_OK=false
    fi
else
    echo "Skipping DNS check (IP address supplied)"
fi

# Layer 2 - Port Check
echo
echo "[Layer 2] Port Check"

NC_OUTPUT=$(nc -zvw3 "$HOST" "$PORT" 2>&1)
NC_STATUS=$?

if [ $NC_STATUS -eq 0 ]; then
    echo "PASS - Port $PORT is OPEN"
    PORT_OK=true
elif echo "$NC_OUTPUT" | grep -qi "refused"; then
    echo "FAIL - Connection REFUSED"
else
    echo "FAIL - Connection TIMED OUT"
fi

# Layer 3 - Local Service Check
echo
echo "[Layer 3] Local Port Owner"

if [[ "$HOST" == "localhost" || "$HOST" == "127.0.0.1" ]]; then
    ss -tulpn | grep ":$PORT"
else
    echo "Skipping local port inspection"
fi

# Layer 5 - HTTP Check
echo
echo "[Layer 5] Application Check"

if [ "$PORT" = "80" ] || [ "$PORT" = "443" ]; then

    if [ "$PORT" = "443" ]; then
        URL="https://$HOST"
    else
        URL="http://$HOST"
    fi

    RESULT=$(curl -s -o /dev/null \
        -w "%{http_code} %{time_total}" \
        --connect-timeout 5 \
        "$URL")

    CODE=$(echo "$RESULT" | awk '{print $1}')
    TIME=$(echo "$RESULT" | awk '{print $2}')

    echo "HTTP Code : $CODE"
    echo "Response Time : ${TIME}s"

    if [[ "$CODE" =~ ^2|3 ]]; then
        HTTP_OK=true
    fi
else
    echo "Skipping HTTP check"
fi

# Final Diagnosis
echo
echo "===================================="
echo " FINAL DIAGNOSIS"
echo "===================================="

if [ "$DNS_OK" = false ]; then
    echo "Problem: DNS Resolution Failure"
    echo "Fix: Check DNS servers in /etc/resolv.conf"
    exit 1
fi

if [ "$PING_OK" = false ]; then
    echo "Problem: Host Unreachable"
    echo "Fix: Check routing, gateway, firewall, or host availability"
    exit 1
fi

if [ "$PORT_OK" = false ]; then
    echo "Problem: Service Not Reachable"

    if echo "$NC_OUTPUT" | grep -qi "refused"; then
        echo "Fix: Service is not listening on port $PORT"
    else
        echo "Fix: Firewall or network is blocking the connection"
    fi

    exit 1
fi

if [ "$PORT" = "80" ] || [ "$PORT" = "443" ]; then

    if [ "$HTTP_OK" = false ]; then
        echo "Problem: Application Error"
        echo "Fix: Check web server logs and application status"
        exit 1
    fi
fi

echo "SUCCESS"
echo "Network, port, and application appear healthy"
echo "===================================="