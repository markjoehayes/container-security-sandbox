#!/usr/bin/env bash
# Network scanning script for attacker container

echo "🔍 Network Discovery Scan"
echo "========================"
echo ""

# Discover containers on attack-path network
echo "1. Scanning attack-path network (172.21.0.0/16):"
nmap -sn 172.21.0.0/16 | grep -E "Nmap scan|Host is up"

echo ""
echo "2. Attempting to reach secure network (should fail):"
ping -c 2 172.22.0.1 2>&1 | grep -E "statistics|unreachable"

echo ""
echo "3. Container discovery complete"
