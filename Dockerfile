# ══════════════════════════════════════════════════════════════════════════════
# Robot Framework Test Container
# 
# Run E2E tests without installing any dependencies locally.
# Usage: docker build -t eventhub-tests . && docker run eventhub-tests
# ══════════════════════════════════════════════════════════════════════════════

# Use Playwright's pre-built image with Chrome already installed
FROM mcr.microsoft.com/playwright:v1.48.0-jammy

# Install Python and pip (playwright image is Ubuntu-based)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Robot Framework and SeleniumLibrary
RUN pip3 install --no-cache-dir --break-system-packages \
    robotframework==7.1.1 \
    robotframework-seleniumlibrary==6.6.1

# Set working directory
WORKDIR /app

# Copy test files
COPY tests/ ./tests/

# Create results directory
RUN mkdir -p results && chmod 777 results

# Default environment variables (override with docker run -e)
ENV BROWSER=headlesschrome
ENV BASE_URL=https://eventhub.rahulshettyacademy.com

# Run tests as non-root user
USER pwuser

# Run tests
CMD ["python3", "-m", "robot", \
     "--outputdir", "results", \
     "--variable", "BROWSER:headlesschrome", \
     "--loglevel", "INFO", \
     "--name", "EventHub E2E Tests", \
     "tests/"]
