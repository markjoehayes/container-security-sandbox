FROM ubuntu:22.04

# Create a non-root user
RUN useradd -m appuser

RUN apt-get update && apt-get install -y \
    bash \
    curl \
    iproute2 \
    procps \
    && rm -rf /var/lib/apt/lists/*

USER appuser
WORKDIR /home/appuser

CMD ["/bin/bash"]

