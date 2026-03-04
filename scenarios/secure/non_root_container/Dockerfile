# scenarios/secure/root_container/Dockerfile
FROM ubuntu:22.04

# Create non-root user first (so we can use it for COPY)
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install only necessary packages (minimal footprint)
RUN apt-get update && apt-get install -y \
    curl \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create application directory with proper permissions
WORKDIR /app

# Copy and set permissions before switching user
COPY --chown=appuser:appuser app.sh /app/
RUN chmod 750 /app/app.sh

# Create secrets file with restricted permissions
RUN echo "DB_PASSWORD=super_secret" > /etc/app_secrets.env && \
    chown root:appuser /etc/app_secrets.env && \
    chmod 640 /etc/app_secrets.env

# Switch to non-root user
USER appuser

# Application runs as non-privileged user
CMD ["./app.sh"]
