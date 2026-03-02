#!/usr/bin/env python3

import json
import subprocess
import sys

SEVERITY_SCORES = {
        "CRITICAL": 5,
        "HIGH": 3,
        "MEDIUM": 2,
        "LOW": 1
}

def run_cmd(cmd):
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout.strip()

def get_container_info(container_id):
    output = run_cmd(["docker", "inspect", container_id])
    return json.loads(output)[0]

def check_root(config):
    user = config["Config"].get("User", "")
    return user == "" or user == "0"

def check_privileged(config):
    return config["HostConfig"].get("Privileged", False)

def check_pid_namespace(config):
    return config["HostConfig"].get("PidMode") == "host"

def check_docker_socket(config):
    mounts = config.get("Mounts", [])
    for mount in mounts:
        if mount.get("Source") == "/var/run/docker.sock":
            return True
    return False

def check_readonly(config):
    return config["HostConfig"].get("ReadonlyRootfs", False)

def check_capabilities(config):
    if config["HostConfig"].get("Priviliged", False):
        return False

    caps = config["HostConfig"].get("CapDrop") or []
    return "ALL" in caps

def report(issue, failed, severity, findings):
    if failed:
        findings.append((issue, severity))
        print(f"{issue} {severity}")
    else:
        print(f"{issue}: OK")

def calculate_risk(findings):
    total = sum(SEVERITY_SCORES[sev] for _, sev in findings)
    if total >= 10:
        return "CRITICAL"
    elif total >= 6:
        return "HIGH"
    elif total >= 3:
        return "MEDIUM"
    elif total > 0:
        return "LOW"
    return "NONE"

def audit(container_id):
    config = get_container_info(container_id)
    findings = []

    print(f"\nAuditing container: {container_id}")
    print("=" * 60)

    report("Running as root",
           check_root(config),
           "HIGH",
           findings)

    report("Priviliged mode",
           check_privileged(config),
           "HIGH",
           findings)

    report("PID namespace host",
           check_pid_namespace(config),
           "HIGH",
           findings)

    report("Docker socket mounted",
           check_docker_socket(config),
           "CRITICAL",
           findings)

    report("Read-only rootfs",
           not check_readonly(config),
           "MEDIUM",
           findings)

    report("Dropped all capabilities",
           not check_capabilities(config),
           "MEDIUM",
           findings)

    print("=" * 60)

    risk_level = calculate_risk(findings)
    print(f"Overall Risk Level: {risk_level}")

    # exit non-zero if insecure
    if risk_level in ["HIGH", "CRITICAL"]:
        sys.exit(1)

#    print("Running as root:", "YES" if check_root(config) else "OK")
#    print("Privileged mode:", "YES" if check_privileged(config) else "OK")
#    print("PID namespace host:", "YES" if check_pid_namespace(config) else "OK")
#    print("Docker socket mounted:", "YES" if check_docker_socket(config) else "OK")
#    print("Read-only rootfs:", "OK" if check_readonly(config) else "NO")
#    print("Dropped all capabilities:", "OK" if check_capabilities(config) else "NO")

#    print("=" * 50)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: ./container_audit.py <container_id>")
        sys.exit(1)

    audit(sys.argv[1])
