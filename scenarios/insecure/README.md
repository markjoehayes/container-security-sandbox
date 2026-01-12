## Insecure Scenario: Root Container

### Description
This container runs processes as the root user by default.

### Why This Is Dangerous
Running containers as root increases the risk of:
- Privilege escalation
- Container breakout
- Host compromise

### Expected Risk
If combined with other misconfigurations, a root container may allow
attackers to impact the host system.

### Learning Objective
Understand why rootless containers are recommended and how default container privileges affect security


## Privileged Container

### Description
This container is run with Docker's --privileged flag, granting it nearly all Linux capabilities and access to host devices.

### Why This is Dangerous
Privleged containers significantly weaken isolation boundaries and may allow attackers to:
- Access host devices
- Modify kernel parameters
- Escape the container environment

Even when capability listings are ambiguous in minimal container images, behavioral testing such as accessing /dev/kmsg, reading kernel logs with dmesg, and successfully mounting filesystems confirms that privileged containers significantly weaken isolation and expose host-level interfaces.

### Learning Objective
Understand how Linux capabilities and device access affect container isolation and why privileged containers should be avoided.
