FROM python:3.9-slim

RUN pip install docker

WORKDIR /auditor

CMD ["tail", "-f", "/dev/null"]

EOF

# Copy your audit script
cp tools/container_audit.py tools/ 2>/dev/null || echo "Please copy your audit script to tools/container_audit.py"
