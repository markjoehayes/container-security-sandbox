FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    bash \
    util-linux \
    iproute2 \
    procps \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]

