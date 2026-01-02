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

