FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    bash \
    curl \
    iproute2 \
    procps \
    vim \
    net-tools \
    sudo \
    vim

RUN echo "DB_PASSWORD=super_secret" > /etc/app_secrets.env

CMD ["sleep", "infinity"]

