#!/usr/bin/env python3

import json
import subprocess
import sys

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
    caps = config["HostConfig"].get("CapDrop", [])
    return "ALL" in caps

def audit(container_id):
    config = get_container_info(container_id)

    print(f"\n🔍 Auditing container: {container_id}")
    print("=" * 50)

    print("Running as root:", "YES" if check_root(config) else "OK")
    print("Privileged mode:", "YES" if check_privileged(config) else "OK")
    print("PID namespace host:", "YES" if check_pid_namespace(config) else "OK")
    print("Docker socket mounted:", "YES" if check_docker_socket(config) else "OK")
    print("Read-only rootfs:", "OK" if check_readonly(config) else "NO")
    print("Dropped all capabilities:", "OK" if check_capabilities(config) else "NO")

    print("=" * 50)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: ./container_audit.py <container_id>")
        sys.exit(1)

    audit(sys.argv[1])
