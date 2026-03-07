FROM ubuntu:22.04

RUN apt update && apt install -y \
    libcap2-bin \
    procps \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
