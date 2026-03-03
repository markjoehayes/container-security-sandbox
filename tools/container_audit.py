#!/usr/bin/env python3

import json
import subprocess
import sys
import argparse

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
    result = subprocess.run(
            ["docker", "inspect", container_id],
            capture_output=True,
            text=True
    )

    if result.returncode != 0:
        print(f"[ERROR] Container '{container_id}' not found.")
        sys.exit(1)
    try:
        data = json.loads(result.stdout)
        return data[0]
    except (json.JSONDecodeError, IndexError):
        print(f"[ERROR] Failed to parse docker inspoect output.")
        sys.exit(1)

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

def check_no_new_privileges(config):
    security_opts = config["HostConfig"].get("SecurityOpt") or []
    return any("no-new-privileges" in opt for opt in security_opts)

def check_capabilities(config):
    if config["HostConfig"].get("Privileged", False):
        return False

    caps = config["HostConfig"].get("CapDrop") or []
    return "ALL" in caps

def report(issue, failed, severity, findings):
    if failed:
        findings.append((issue, severity))
        print(f"{issue}: {severity}")
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

def audit(container_id, json_output=False):
    config = get_container_info(container_id)
    findings = []
    report_data = []

    checks = [
            ("Running as root", check_root(config), "HIGH"),
            ("Privileged mode", check_privileged(config), "CRITICAL"),
            ("PID namespace host", check_pid_namespace(config), "HIGH"),
            ("Docker socket mounted", check_docker_socket(config), "CRITICAL"),
            ("Read-only rootfs", not check_readonly(config), "MEDIUM"),
            ("Dropped all capabilities", not check_capabilities(config), "MEDIUM"),
            ("no-new-privileges not set", not check_no_new_privileges(config), "HIGH"),
    ]

    for issue, failed, severity in checks:
        if failed:
            findings.append((issue, severity))

        report_data.append({
            "issue": issue,
            "status": "FAIL" if failed else "PASS",
            "severity": severity if failed else None
        })

    risk_level = calculate_risk(findings)

    if json_output:
        output = {
                "container": container_id,
                "overall_risk": risk_level,
                "findings": report_data
        }
        print(json.dumps(output, indent=2))
    else:
        print(f"\nAuditing container: {container_id}")
        print("=" * 60)

        for item in report_data:
            if item["status"] == "FAIL":
                print(f"{item['issue']} {item['severity']}")
            else:
                print(f"{item['issue']}: OK")

    print("=" * 60)

    print(f"Overall Risk Level: {risk_level}")

    # exit non-zero if insecure
    if risk_level in ["HIGH", "CRITICAL"]:
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Container Runtime Audit Tool")
    parser.add_argument("container", help="Container name or ID")
    parser.add_argument("--json", action="store_true", help="Output results in JSON format")
    args = parser.parse_args()
    audit(args.container, args.json)
