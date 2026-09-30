# ==========================================
# Stage 1: Build & Dependency Isolation
# ==========================================
FROM python:3.11-slim AS builder

WORKDIR /app

# Install system dependencies if your Python wheels need compilation (optional for basic Flask)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install dependencies into a localized wheels/ folder to copy over later
RUN pip wheel --no-cache-dir --wheel-dir /app/wheels -r requirements.txt


# ==========================================
# Stage 2: Final Lightweight Runtime
# ==========================================
FROM python:3.11-slim AS runner

WORKDIR /app

# Create a non-privileged system user for application execution security
RUN useradd -u 10001 -m appuser

# Copy over compiled wheels from the builder stage
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .

# Install the wheels locally without fetching from internet registries
RUN pip install --no-cache --no-index --find-links=/wheels -r requirements.txt \
    && rm -rf /wheels

# Copy application source code
COPY app/ ./app/

# Enforce secure file ownership configurations
RUN chown -R appuser:appuser /app

# Switch executing context away from root privileges
USER appuser

EXPOSE 5000

# Use an environment variable to ensure logs write directly to stdout/stderr
ENV PYTHONUNBUFFERED=1

CMD ["python", "app/main.py"]
