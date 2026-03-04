# Container Hardening Guide

## Security Features Implemented

### 1. Non-Root User
- **Why**: Limits damage if container is compromised
- **Implementation**: `USER appuser` in Dockerfile
- **Verification**: `docker exec container whoami`

### 2. Read-Only Root Filesystem
- **Why**: Prevents binary modification and backdoor installation
- **Implementation**: `--read-only` flag
- **Exception**: `/tmp` mounted as tmpfs for temporary writes

### 3. Dropped Capabilities
- **Why**: Removes unnecessary kernel privileges
- **Implementation**: `--cap-drop=ALL --cap-add=NET_BIND_SERVICE`
- **Result**: Container can only bind to network ports

### 4. No New Privileges
- **Why**: Prevents privilege escalation attacks
- **Implementation**: `--security-opt=no-new-privileges:true`
- **Protects against**: CVE-2019-5736, sudo escalation

### 5. Temporary Filesystem
- **Why**: Allows writes without persisting or compromising host
- **Implementation**: `--tmpfs /tmp:rw,noexec,nosuid,size=100m`
- **Benefits**: Ephemeral, limited size, no execution of binaries
