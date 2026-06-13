#!/bin/bash

TARGET=${1:-"google.com"}

echo "========================================"
echo "  Network Diagnostic: $TARGET"
echo "  $(date)"
echo "========================================"

# 1. Network Information
echo -e "\n[Network Info]"
echo "IP Addresses:"
ip -4 addr show | grep inet

echo -e "\nGateway:"
ip route | grep default

echo -e "\nDNS Servers:"
grep nameserver /etc/resolv.conf

# 2. Ping Check
echo -e "\n[Ping Test]"

PING_OUTPUT=$(ping -c 4 "$TARGET" 2>/dev/null)

if [ $? -eq 0 ]; then
    AVG_TIME=$(echo "$PING_OUTPUT" | tail -1 | awk -F'/' '{print $5}')
    echo "PASS - Average Response Time: ${AVG_TIME} ms"
else
    echo "FAIL - Host unreachable"
fi

# 3. DNS Resolution
echo -e "\n[DNS Resolution]"

IP=$(dig +short "$TARGET" | head -1)

if [ -n "$IP" ]; then
    echo "$TARGET resolves to $IP"
else
    echo "DNS lookup failed"
fi

# 4. HTTP Check
echo -e "\n[HTTP Check]"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://$TARGET")

if [ "$HTTP_CODE" = "200" ]; then
    echo "PASS - HTTP Status: $HTTP_CODE"
else
    echo "FAIL - HTTP Status: $HTTP_CODE"
fi

# 5. Port Checks
echo -e "\n[Port Check]"

for PORT in 22 80 443
do
    timeout 2 bash -c "</dev/tcp/$TARGET/$PORT" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "Port $PORT : OPEN"
    else
        echo "Port $PORT : CLOSED"
    fi
done

# 6. Hop Count
echo -e "\n[Traceroute]"

HOPS=$(traceroute -m 30 "$TARGET" 2>/dev/null | tail -1 | awk '{print $1}')

if [ -n "$HOPS" ]; then
    echo "Hops to reach target: $HOPS"
else
    echo "Unable to determine hop count"
fi

# 7. Summary
echo
echo "========================================"
echo "SUMMARY"
echo "Target: $TARGET"
echo "Resolved IP: ${IP:-N/A}"
echo "HTTP Status: ${HTTP_CODE:-N/A}"
echo "========================================"