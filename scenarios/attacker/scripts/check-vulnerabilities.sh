#!/bin/bash
echo "🎯 Targeted Attack Scripts"
echo "=========================="

# Check for privileged container
echo "1. Testing privileged container escape:"
if docker exec sandbox-privileged-insecure ls /host 2>/dev/null; then
    echo "   ✅ Privileged container can access host!"
else
    echo "   ❌ Cannot access host"
fi

# Check for Docker socket abuse
echo ""
echo "2. Testing Docker socket abuse:"
if docker exec sandbox-sock-insecure docker ps 2>/dev/null | grep -q sandbox; then
    echo "   ✅ Can control host Docker daemon!"
else
    echo "   ❌ Cannot access Docker"
fi
