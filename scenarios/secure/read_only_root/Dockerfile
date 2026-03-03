
FROM ubuntu:22.04

RUN useradd -m appuser

RUN apt update && apt install -y \
    libcap2-bin \
    procps \
    && rm -rf /var/lib/apt/lists/*

USER appuser

CMD ["/bin/bash"]
