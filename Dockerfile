FROM python:3.12-slim AS base

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install System Dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         build-essential gcc \
    && python -m pip install --upgrade pip \
    && rm -rf /var/lib/apt/lists/*


# Set working directory
WORKDIR /app

# Copy only setup-related files first (leverages Docker layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt \
                            && rm requirements.txt

# Copy application code
COPY app /app/app

# Create and switch to non-root user
RUN useradd -m fastapiuser
USER fastapiuser

# Expose app port
EXPOSE 8000

# Start the FastAPI app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
