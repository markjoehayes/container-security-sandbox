#!/usr/bin/env bash
# demos/compare-insecure-vs-secure.sh

echo "=========================================="
echo "|  Insecure vs Secure Container Compare  |"
echo "=========================================="
echo ""

# Run insecure container
echo "INSECURE CONTAINER"
echo "---------------------"
docker run -d --name insecure-compare insecure-root > /dev/null
../tools/container_audit.py insecure-compare | grep -E "Running as|Privileged|Read-only|Dropped|no-new-privileges|Overall"
docker stop insecure-compare > /dev/null
docker rm insecure-compare > /dev/null
echo ""

# Run secure container
echo "SECURE CONTAINER"
echo "------------------"
docker run -d \
    --name secure-compare \
    --read-only \
    --cap-drop=ALL \
    --cap-add=NET_BIND_SERVICE \
    --security-opt=no-new-privileges:true \
    secure-app > /dev/null

../tools/container_audit.py secure-compare | grep -E "Running as|Privileged|Read-only|Dropped|no-new-privileges|Overall"
docker stop secure-compare > /dev/null
docker rm secure-compare > /dev/null
echo ""

echo "=========================================="
echo "|  Secure container addresses all risks  |"
echo "=========================================="
