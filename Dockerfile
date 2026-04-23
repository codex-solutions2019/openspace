FROM python:3.12-slim AS builder

WORKDIR /app

# Install build deps
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*

# Copy and install core deps only (skip pyautogui, pyobjc, etc.)
COPY requirements.txt .
# Remove problematic GUI/platform deps
RUN sed -i '/pyautogui/d; /pyobjc/d; /pywin32/d; /pygetwindow/d; /pyatspi/d; /python-xlib/d; /pywinauto/d' requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN pip install --no-cache-dir -e . --no-deps

FROM python:3.12-slim

WORKDIR /app

# Install runtime deps only
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/openspace* /usr/local/bin/
COPY --from=builder /app /app

ENV OPENSPACE_TRANSPORT=streamable-http
ENV OPENSPACE_HOST=0.0.0.0
ENV OPENSPACE_PORT=8081

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8081/')" || exit 1

CMD ["openspace-mcp", "--transport", "streamable-http", "--host", "0.0.0.0", "--port", "8081"]
