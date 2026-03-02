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

---

## Lab Structure

The project includes:

- Insecure container configurations
- Hardened container baselines
- Documented attack narratives
- A custom container security audit tool

---

## Attacks Demonstrated

### 1. Root Container Abuse
Running a container as root increases kernel attack surface.

### 2. Privileged Container Escalation
Using `--privileged` removes most isolation controls.

### 3. Docker Socket Mount → Host Control
Mounting `/var/run/docker.sock` allows a container to control the Docker daemon (effectively root on host).

More attack scenarios are in progress.

---

## Hardened Baseline

The secure container configuration includes:

- Non-root user
- Dropped Linux capabilities
- Read-only root filesystem
- No Docker socket exposure
- No privileged mode

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

---

## Quick Start

### 1. Clone the repository

```bash
git clone git@github.com:markjoehayes/container-security-sandbox.git
cd container-security-sandbox
````

### 2. Build Containers

Build insecure container:

```bash
docker build -t test_insecure -f docker/insecure.Dockerfile .
```

Build secure container:

```bash
docker build -t test_secure -f docker/secure.Dockerfile .
```

---

### 3. Run Containers

Insecure:

```bash
docker run -d --name test_insecure --privileged test_insecure
```

Secure:

```bash
docker run -d --name test_secure \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  test_secure
```

---

### 4. Run the Audit Tool

```bash
./tools/container_audit.py test_insecure
```

Example output:

```
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

