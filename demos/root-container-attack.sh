#!/usr/bin/env bash

echo "===Root Container Attack Demo ==="

# Build and Run vulnerable container
echo "1. Building vulnerable container..."
docker build -t insecure-root -f ../scenarios/insecure/root_container/Dockerfile .

echo "2. Running container..."
docker run -d --name vulnerable-root insecure-root

# wait for container to be ready
sleep 4

echo ""

echo "3. Running security audit on container:"
echo "================================================"
../tools/container_audit.py test_insecure
echo "================================================"

echo ""

echo "4. Demontrating attack based on audit findings..."
echo "  a. Container runs as root (HIGH severity finding):"
docker exec -it vulnerable-root /bin/bash -c "whoami && id"

echo "  b. Reading sensitive file:"
docker exec -it vulnerable-root /bin/bash -c "cat /etc/app_secrets.env"

echo "  c. Attempting host access (simulated):"
docker exec -it vulnerable-root /bin/bash -c "ls -la /host 2>/dev/null || 
    echo 'Cannot access host directly'"

echo "4. Cleanup..."
docker stop vulnerable-root
docker rm vulnerable-root
