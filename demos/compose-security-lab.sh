#!/usr/bin/env bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Container Security Sandbox - Complete Lab Demo         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Cleanup any existing environment
echo "1. Cleaning up previous environment..."
docker-compose down -v 2>/dev/null
echo " Cleanup complete"
echo ""

# Build and start the lab
echo "2. Building and starting security lab..."
echo "   (This may take a few minutes for the first build)"
docker-compose build --parallel
docker-compose up -d
echo " Lab environment ready"
echo ""

# Show running containers
echo "3. Running containers:"
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Services}}"
echo ""

# Run security audit on all containers
echo "4. Running comprehensive security audit:"
echo "════════════════════════════════════════════════════════════"
for container in $(docker ps --format "{{.Names}}" | grep sandbox); do
    if [[ $container != "auditor" ]] && [[ $container != "attacker" ]]; then
        echo "Container: $container"
        python3 tools/container_audit.py $container 2>/dev/null || docker exec sandbox-auditor python3 /tools/container_audit.py $container 2>/dev/null
        echo "===================================================="
    fi
done

echo ""

# Demonstrate attacks
echo "5. Launching attack demonstrations..."
echo ""
echo "   a. Network reconnaissance:"
docker exec sandbox-attacker /attacks/scan-network.sh
echo ""

echo "   b. Vulnerability checking:"
docker exec sandbox-attacker /attacks/check-vulnerabilities.sh
echo ""

# Show network isolation
echo "6. Network isolation verification:"
echo "   Testing connectivity between networks..."
docker exec sandbox-attacker ping -c 1 sandbox-root-secure 2>&1 | grep -q "unreachable" && \
    echo "    Secure network properly isolated from attacker" || \
    echo "    Secure network should be isolated!"
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Lab Demo Complete                                         ║"
echo "║                                                            ║"
echo "║  Next steps:                                               ║"
echo "║  • docker-compose logs -f [service]  (view logs)           ║"
echo "║  • docker exec -it sandbox-attacker bash (attack manually) ║"
echo "║  • docker-compose down            (cleanup)                ║"
echo "╚════════════════════════════════════════════════════════════╝"
