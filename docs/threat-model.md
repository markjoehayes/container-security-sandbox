# Threat Model

## Attack Vectors
1. **Container Breakout**
   - Privilege escalation to host
   - Namespace escape

2. **Credential Theft**
   - Environment variable exposure
   - Mounted secret access

3. **Resource Abuse**
   - CPU/Memory exhaustion
   - Host filesystem filling

## Mitigation Strategies
- Least privilege principle
- Read-only filesystems
- Network segmentation
