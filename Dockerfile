# syntax=docker/dockerfile:1
# Multi-purpose image for the LMS Django/Channels (ASGI) application.
FROM python:3.12-slim AS base

# Keep Python lean and unbuffered inside containers.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    DJANGO_SETTINGS_MODULE=LMSProject.settings

WORKDIR /app

# OS deps: build toolchain for packages that ship no wheel (e.g. traits),
# plus curl for the container healthcheck.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies first to leverage Docker layer caching.
COPY requirements.txt .
RUN pip install -r requirements.txt

# Application source.
COPY . .

# Run as an unprivileged user.
RUN adduser --disabled-password --gecos "" appuser \
    && mkdir -p /app/media /app/static_root /app/db \
    && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "LMSProject.asgi:application"]
