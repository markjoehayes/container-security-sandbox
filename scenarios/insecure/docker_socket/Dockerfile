FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    bash \
    curl \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]

