# Container Security Sandbox

A hands-on Linux lab demonstrating container misconfigurations, real exploitation techniques, and defensive hardening strategies.

This project explores how Docker runtime configuration choices directly impact container isolation and host security.

---

## Overview

Containers are often assumed to provide strong isolation by default.

This lab demonstrates:

- How misconfigurations break isolation
- How attackers escalate from container to host
- How hardened configurations prevent abuse
- How security checks can be automated
- Multi-container orchestration with Docker Compose
- Network segmentation and isolation

---

## Lab Structure

The project includes:

- Insecure container configurations
- Hardened container baselines
- Attacker container, preconfigured with network scanning tools
- Auditor container for continuous security monitoring
- Network policy enforcer for isolation demonstration
- Documented attack narratives
- A custom container security audit tool (Python)
- Automated demo scripts: secure, insecure and comparison
- Docker Compose orchestration for one-command lab deployment

---

## Attacks Demonstrated

### 1. Root Container Abuse
Running a container as root increases kernel attack surface. While root in a container can't directly access the host, it can:
- Read all container secrets
- Install additional tools
- Attempt kernel exploits

### 2. Privileged Container Escalation
Using `--privileged` removes most isolation controls, allowing:
- Host filesystem access
- Device manipulation
- Kernel module loading
- Full host compromise

### 3. Docker Socket Mount → Host Control
Mounting `/var/run/docker.sock` allows a container to control the Docker daemon (effectively root on host):
- Launch new privileged containers
- Access all container data
- Control host Docker operations

### 4. Excessive Capabilities
Adding capabilities like `CAP_SYS_ADMIN` allows:
- Mounting filesystems
- Manipulating network configuration
- Bypassing filesystem permissions

### 5. Writable Filesystem
A writable root filesystem allows attackers to:
- Modify binaries
- Plant backdoors
- Persist malicious code

More attack scenarios are in progress.

---

## Hardened Baseline

The secure container configuration includes:

- Non-root user
- Dropped Linux capabilities
- Read-only root filesystem
- No Docker socket exposure
- No privileged mode
- No new privileges - Prevents privilege escalation
- Temporary filesystem - Allows limited writes without persistence

This baseline is used to validate mitigations.

---

## Container Audit Tool

The project includes a custom audit script:

```

tools/container_audit.py

````

It evaluates a running container for common security risks and assigns severity levels.

### Checks Performed

- Running as root
- Privileged mode
- Host PID namespace
- Docker socket mount
- Read-only root filesystem
- Linux capability drops
- No-new-privileges setting

---

## Quick Start

### 1. Clone the repository

```bash
git clone git@github.com:markjoehayes/container-security-sandbox.git
cd container-security-sandbox
````

### 2. Launch the Complete Lab (Docker Compose)

# Build all containers

```bash
docker-compose build
```

# Start the entire environment
docker-compose up -d

# Verify all containers are running
docker-compose ps

### 3. Run Security Audits

# Audit an insecure container
python3 tools/container_audit.py sandbox-root-insecure

# Audit a secure container
python3 tools/container_audit.py sandbox-nonroot-secure

# Audit all containers with JSON output
for container in $(docker ps --format "{{.Names}}" | grep sandbox); do
    python3 tools/container_audit.py $container --json
done



### 4. Launch Attacks from Attacker Container

# Enter the attacker container
docker exec -it sandbox-attacker bash

# Scan the network
./attacks/scan-network.sh

# Test for vulnerabilities
./attacks/check-vulnerabilities.sh

# Ping insecure containers
ping -c 2 sandbox-root-insecure

### 5. View Audit Results Dashboard

# Run the comparison dashboard
./demos/audit_comparison.sh


Auditing container: test_insecure
============================================================
Running as root HIGH
Privileged mode CRITICAL
PID namespace host: OK
Docker socket mounted: OK
Read-only rootfs MEDIUM
Dropped all capabilities MEDIUM
============================================================
Overall Risk Level: CRITICAL
```

---

### JSON Output (CI/CD Integration)

```bash
./tools/container_audit.py test_insecure --json
```

Example:

```json
{
  "container": "test_insecure",
  "overall_risk": "CRITICAL",
  "findings": [
    {
      "issue": "Running as root",
      "status": "FAIL",
      "severity": "HIGH"
    }
  ]
}
```

---

## Risk Model

Severity Levels:

* **CRITICAL** – Immediate host compromise possible
* **HIGH** – Significant privilege escalation risk
* **MEDIUM** – Increased attack surface
* **PASS** – No issue detected

Overall risk is calculated based on highest severity finding.

---

## Educational Purpose

This repository is intended for:

* Security education
* DevSecOps learning
* Demonstrating container isolation boundaries
* Understanding Docker runtime security

This lab should only be used in isolated, controlled environments.

---

## Roadmap

* Additional exploit scenarios
* Seccomp and AppArmor evaluation
* CI pipeline integration
* Extended compliance checks

---

## Author

Mark J. Hayes

```

