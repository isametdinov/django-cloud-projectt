FROM python:3.9-slim-bullseye

ARG APP_NAME=django_crm

# Install system packages
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    build-essential \
    libpq-dev \
    libmariadb-dev \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libwebp-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Setup user
RUN useradd -ms /bin/bash ubuntu
USER ubuntu

# Create app directory
RUN mkdir -p /home/ubuntu/"$APP_NAME"
WORKDIR /home/ubuntu/"$APP_NAME"

# Copy requirements first for better caching
COPY requirements.txt .

# Create and use virtualenv
RUN python3 -m venv venv && \
    venv/bin/pip install -U pip && \
    venv/bin/pip install -r requirements.txt gunicorn

# Copy remaining files
COPY . .

# Explicitly add venv to PATH
ENV PATH="/home/ubuntu/$APP_NAME/venv/bin:${PATH}"

# Verify gunicorn is in PATH
RUN which gunicorn

# ✅ Corrected line below
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "crm.wsgi:application"]
