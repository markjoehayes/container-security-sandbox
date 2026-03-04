# scenarios/secure/root_container/app.sh
#!/bin/bash

echo "Secure Container Started"
echo "Running as: $(whoami)"
echo "User ID: $(id -u)"

# Simulate reading config (with proper permissions)
if [ -r /etc/app_secrets.env ]; then
    echo "Can read configuration (with proper permissions)"
else
    echo "Cannot read configuration"
fi

# Try to write to root filesystem (should fail)
if touch /test-writable 2>/dev/null; then
    echo "Filesystem is writable - UNSAFE!"
else
    echo "Filesystem is read-only - SECURE"
fi

# Try to check capabilities
echo "Current capabilities:"
cat /proc/$$/status | grep Cap | head -3

# Keep container running
echo ""
echo "Container running securely. Press Ctrl+C to stop."
tail -f /dev/null
