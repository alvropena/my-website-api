# Use an official lightweight Python image
FROM python:3.11-slim

# Set the locale
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip poetry
ENV POETRY_VIRTUALENVS_CREATE=false

# Set the working directory in the container
WORKDIR /code

# Copy the dependencies file to the working directory
COPY pyproject.toml poetry.lock* /code/

# Environment variable to control whether to install dev dependencies
ARG ENVIRONMENT="prod"

# Install dependencies
RUN if [ "$ENVIRONMENT" = "prod" ]; then poetry install --no-dev; else poetry install; fi

# Copy your application's code
COPY . /code

# Make docker-entrypoint.sh executable
COPY docker-entrypoint.sh /code/
RUN chmod +x /code/docker-entrypoint.sh

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' myuser && \
    chown -R myuser:myuser /code
USER myuser

# Expose the port the app runs on
EXPOSE 8000

# Healthcheck to ensure service is running
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:8000/ || exit 1

# Use the entrypoint script to configure how the container starts
ENTRYPOINT ["/code/docker-entrypoint.sh"]

# Default command
CMD ["start", "8000"]
