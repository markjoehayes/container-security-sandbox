#!/usr/bin/env bash


echo "=========================================="
echo "| Root Container Attack Demo with Audit  |"
echo "=========================================="
echo ""
echo ""

# Clean up any existing container with same name
echo "0. Cleaning up old containers..."
docker stop demo-insecure 2>/dev/null
docker rm demo-insecure 2>/dev/null
echo "Cleanup complete"
echo " "

# Build and Run vulnerable container
echo "1. Building vulnerable container..."
docker build -t insecure-root -f ../scenarios/insecure/root_container/Dockerfile .
echo "Build Complete"
echo ""


echo "2. Running container..."
CONTAINER_ID=$(docker run -d --name demo-insecure insecure-root)

# Check if container started successfully
if [ $? -ne 0 ]; then
    echo "Failed to start container"
    exit 1
fi

echo "Container started with id: ${CONTAINER_ID}"
echo ""

# wait for container to be ready
sleep 4

echo ""

# Verify container is running
if ! docker ps | grep -q demo-insecure; then
    echo "Container is not running. Checking logs..."
    docker logs demo-insecure
    exit 1
fi


# Run security Audit
echo "3. Running security audit on container:"
echo "================================================"
./tools/container_audit.py demo-insecure
AUDIT_RESULT=$?
echo "================================================"

echo ""

echo "4. Demontrating attack based on audit findings..."
echo "   Finding #1: Container runs as root (HIGH severity):"
echo "   Command: docker exec demo-insecure whoami"
echo "   Result: $(docker exec demo-insecure whoami) "
echo ""


echo "   Finding #2: Can access sensitive files (due to root)"
echo "   Command: docker exec demo-insecure cat /etc/app_secrets.env"
echo "   Result: $(docker exec demo-insecure cat /etc/app_secrets.env)"
echo ""

echo "   Finding #3: Attempting host escape (should fail - demonstrating isolation)"
echo "    Command: docker exec demo-insecure ls /host"
if docker exec demo_insecure ls /host 2>/dev/null; then
    echo "   UNEXPECTED: Container can access host!"
else
    echo "   Expected: Cannot access host (basic isolation works)"
fi
echo ""

echo "5. Cleanup..."
docker stop demo-insecure > /dev/null
docker rm demo-insecure > /dev/null
echo "CLEANUP COMPLETE"

echo "========================================"
echo "|         Demo Complete                |"
echo "|    Container Risk level: CRITICAL    |"
echo "========================================"
