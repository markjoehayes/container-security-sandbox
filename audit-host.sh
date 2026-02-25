# Save this as scripts/audit-host.sh
#!/bin/bash
echo "== Host Security Audit for Sandbox =="
docker version --format '{{.Server.Version}}'
docker info | grep -E "Security|Rootless|Cgroup"

# Check if running in a VM (Recommended)
systemd-detect-virt
