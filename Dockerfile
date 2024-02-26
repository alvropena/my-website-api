# Use an official lightweight Python image
FROM python:3.11-slim

# Environment variable to control whether to install dev dependencies
ARG ENVIRONMENT="prod"

# Update and install system dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl locales && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip poetry
ENV POETRY_VIRTUALENVS_CREATE=false

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' myuser
USER myuser

# Set the working directory in the container
WORKDIR /code

# Copy the dependencies file to the working directory
COPY pyproject.toml poetry.lock* /code/

# Conditionally install dependencies
RUN if [ "$ENVIRONMENT" = "prod" ]; then poetry install --no-dev; else poetry install; fi

# Copy the rest of your application's code
COPY . /code

# Expose the port the app runs on
EXPOSE 8000

# Add docker-entrypoint.sh script to the container
COPY docker-entrypoint.sh /code/
RUN chmod +x /code/docker-entrypoint.sh

# Healthcheck to ensure service is running
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/healthz || exit 1

# Use the entrypoint script to configure how the container starts
ENTRYPOINT ["/code/docker-entrypoint.sh"]

# Default command
CMD ["start", "8000"]
