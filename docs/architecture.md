```mermaid
graph TB
    subgraph "Host System"
        H[Linux Kernel]
        HD[Docker Daemon]
    end
    
    subgraph "Container A - Vulnerable"
        A1[Root Process]
        A2[Mounted Docker Socket]
        A3[Privileged Mode]
    end
    
    subgraph "Container B - Hardened"
        B1[Non-root User]
        B2[Read-only FS]
        B3[Dropped Capabilities]
    end
    
    A1 -->|Breakout Attempt| H
    A2 -->|Control Docker| HD
    B1 -->|Contained| H
