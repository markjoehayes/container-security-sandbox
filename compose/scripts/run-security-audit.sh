#!/bin/bash
# Run security audit on all containers

echo " Complete Security Audit Report"
echo "=================================="
echo ""

# Get all running containers
CONTAINERS=$(docker ps --format "{{.Names}}" | grep sandbox)

for container in $CONTAINERS; do
    echo " Auditing: $container"
    echo "----------------------------------------"
    docker exec sandbox-auditor python3 /tools/container_audit.py $container 2>/dev/null || \
        ./tools/container_audit.py $container
    echo ""
done

# Generate summary
echo "=================================="
echo "📈 Security Posture Summary"
echo "=================================="

# Count by risk level
CRITICAL=$(docker ps --format "{{.Names}}" | grep sandbox | xargs -I {} ./tools/container_audit.py {} 2>&1 | grep "Overall Risk" | grep -c "CRITICAL")
HIGH=$(docker ps --format "{{.Names}}" | grep sandbox | xargs -I {} ./tools/container_audit.py {} 2>&1 | grep "Overall Risk" | grep -c "HIGH")
MEDIUM=$(docker ps --format "{{.Names}}" | grep sandbox | xargs -I {} ./tools/container_audit.py {} 2>&1 | grep "Overall Risk" | grep -c "MEDIUM")
LOW=$(docker ps --format "{{.Names}}" | grep sandbox | xargs -I {} ./tools/container_audit.py {} 2>&1 | grep "Overall Risk" | grep -c "LOW")

echo " CRITICAL: $CRITICAL containers"
echo " HIGH: $HIGH containers"
echo " MEDIUM: $MEDIUM containers"
echo " LOW: $LOW containers"
