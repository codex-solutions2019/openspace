FROM python:3.12-slim

WORKDIR /app

# Install system deps for pyautogui etc (minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN pip install --no-cache-dir -e .

# MCP server with streamable-http transport
ENV OPENSPACE_TRANSPORT=streamable-http
ENV OPENSPACE_HOST=0.0.0.0
ENV OPENSPACE_PORT=8081

EXPOSE 8081

CMD ["openspace-mcp", "--transport", "streamable-http", "--host", "0.0.0.0", "--port", "8081"]
