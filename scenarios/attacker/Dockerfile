FROM kalilinux/kali-rolling

# Install attack tools
RUN apt-get update && apt-get install -y \
    nmap \
    netcat-traditional \
    curl \
    wget \
    docker.io \
    iproute2 \
    iputils-ping \
    tcpdump \
    hydra \
    gobuster \
    metasploit-framework \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create attack scripts directory
WORKDIR /attacks

# Copy attack scripts
COPY scripts/ /attacks/

# Make scripts executable
RUN chmod +x /attacks/*.sh

CMD ["/bin/bash"]
