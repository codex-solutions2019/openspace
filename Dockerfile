FROM python:3.12-slim

WORKDIR /app

# Minimal system deps
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN pip install --no-cache-dir -e . --no-deps

ENV OPENSPACE_TRANSPORT=streamable-http
ENV OPENSPACE_HOST=0.0.0.0
ENV OPENSPACE_PORT=8081

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8081/health')" || exit 1

CMD ["openspace-mcp", "--transport", "streamable-http", "--host", "0.0.0.0", "--port", "8081"]
