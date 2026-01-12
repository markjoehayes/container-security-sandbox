FROM ubuntu:22.04

RUN useradd -m appuser

RUN apt-get update && apt-get install -y \
    bash \
    iproute2 \
    procps \
    libcap2-bin \
    && rm -rf /var/lib/apt/lists/*

USER appuser
WORKDIR /home/appuser

CMD ["/bin/bash"]

