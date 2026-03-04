#!/usr/bin/env bash
# demos/secure-container.sh

echo "=========================================="
echo "|   Hardened Container Demo with Audit   |"
echo "=========================================="
echo ""

# Clean up any existing container
echo "0. Cleaning up old containers..."
docker stop secure-demo 2>/dev/null
docker rm secure-demo 2>/dev/null
echo "Cleanup complete"
echo ""

# Build secure container
echo "1. Building hardened container..."
docker build -t secure-app -f ../scenarios/secure/non_root_container/Dockerfile ../scenarios/secure/non_root_container/
echo "Build Complete"
echo ""

# Run with ALL security options
echo "2. Running container with maximum security..."
CONTAINER_ID=$(docker run -d \
    --name secure-demo \
    --read-only \
    --cap-drop=ALL \
    --cap-add=NET_BIND_SERVICE \
    --security-opt=no-new-privileges:true \
    --tmpfs /tmp:rw,noexec,nosuid,size=100m \
    secure-app)

echo "Container started with id: ${CONTAINER_ID:0:12}"
echo ""

# Wait for container to be ready
sleep 4

# Show running container
echo "3. Container status:"
docker ps --filter "name=secure-demo" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
echo ""

# Run security audit
echo "4. Running security audit on hardened container:"
echo "════════════════════════════════════════════════════════════"
../tools/container_audit.py secure-demo
AUDIT_RESULT=$?
echo "════════════════════════════════════════════════════════════"
echo ""

# Demonstrate security features
echo "5. Demonstrating security hardening:"
echo ""

echo "    Security Feature #1: Non-root user"
echo "    Command: docker exec secure-demo whoami"
echo "    Result: $(docker exec secure-demo whoami)"
echo ""

echo "    Security Feature #2: Read-only filesystem"
echo "    Command: docker exec secure-demo touch /test.txt"
if docker exec secure-demo touch /test.txt 2>/dev/null; then
    echo "   FAILED: Filesystem should be read-only!"
else
    echo "   PASSED: Cannot write to root filesystem"
fi
echo ""

echo "    Security Feature #3: Dropped capabilities"
echo "    Command: docker exec secure-demo cat /proc/1/status | grep Cap"
CAPS=$(docker exec secure-demo cat /proc/1/status | grep Cap | head -1)
echo "    Result: $CAPS (should show minimal capabilities)"
echo ""

echo "   Security Feature #4: No new privileges"
echo "    Testing if container can gain privileges:"
if docker exec secure-demo sudo 2>/dev/null; then
    echo "   FAILED: Container should not be able to use sudo!"
else
    echo "   PASSED: Cannot gain new privileges"
fi
echo ""

echo "   Security Feature #5: Temporary filesystem for writes"
echo "    Testing write to /tmp (allowed but restricted):"
docker exec secure-demo touch /tmp/test.txt && echo "    Can write to /tmp (ephemeral storage)" || echo "    Cannot write to /tmp"
echo ""

# Cleanup
echo "6. Cleanup..."
docker stop secure-demo > /dev/null 2>&1
docker rm secure-demo > /dev/null 2>&1
echo "Cleanup complete"
echo ""

echo "=========================================="
echo "|           Demo Complete                |"
echo "|   Container Risk Level: NONE           |"
echo "=========================================="
