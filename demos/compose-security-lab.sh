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
docker-compose ps
echo ""

# Run security audit
echo "4. Running comprehensive security audit:"
echo "════════════════════════════════════════════════════════════"
./compose/scripts/run-security-audit.sh
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
