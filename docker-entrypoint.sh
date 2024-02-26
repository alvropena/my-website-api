#!/bin/bash
set -e

PORT=${2:-8000}

case "$1" in
    start)
        echo "Starting Uvicorn with web application on port ${PORT}"
        exec uvicorn main:app --host 0.0.0.0 --port $PORT --reload
        ;;
    tests)
        echo "Running tests..."
        exec pytest -s -vv tests/
        ;;
    *)
        exec "$@"
        ;;
esac
