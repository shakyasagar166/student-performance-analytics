FROM python:3.10-slim

WORKDIR /app

# Install system dependencies if needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project code
COPY . .

# Environment configuration
ENV PORT=8000
EXPOSE 8000

# Start full-stack connected server
CMD ["python", "server.py"]
