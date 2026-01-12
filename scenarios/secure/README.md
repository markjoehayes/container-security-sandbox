# Secure Container Scenarios

## Non-Root Container

### Description
This container runs processes as a non-root user by default.

### Security Benefit
Running containers as non-root reduces the impact of a compromise by
limiting access to privileged system resources.

### Mitigation
This configuration mitigates risks associated with default root
containers by enforcing the principle of least privilege.


## Drpped Capabilities Container

### Description
This container runs as non-root user with all Linux capabilities explicity dropped at runtime.

### Security Benefit
Dropping capablities significantly reduces the container's ability to interact with the host system, even if the application is compromised.

### Mitigation
This configuration replaces privileged containers by enforcing least privilege through explicit capability restrictions.
