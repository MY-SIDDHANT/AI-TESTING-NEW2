# ══════════════════════════════════════════════════════════════════════════════
# Robot Framework Test Container
# 
# Run E2E tests without installing any dependencies locally.
# Usage: docker build -t eventhub-tests . && docker run eventhub-tests
# ══════════════════════════════════════════════════════════════════════════════

# Multi-platform compatible base image
FROM --platform=linux/amd64 python:3.11-slim-bookworm

# Install Chrome dependencies and utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    unzip \
    curl \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libwayland-client0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update \
    && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

# Install matching ChromeDriver
RUN CHROME_VERSION=$(google-chrome --version | grep -oP '\d+' | head -1) \
    && DRIVER_URL="https://storage.googleapis.com/chrome-for-testing-public/$(curl -s https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_${CHROME_VERSION})/linux64/chromedriver-linux64.zip" \
    && wget -q "$DRIVER_URL" -O /tmp/chromedriver.zip \
    && unzip /tmp/chromedriver.zip -d /tmp/ \
    && mv /tmp/chromedriver-linux64/chromedriver /usr/local/bin/ \
    && chmod +x /usr/local/bin/chromedriver \
    && rm -rf /tmp/*

# Install Robot Framework and SeleniumLibrary
RUN pip install --no-cache-dir \
    robotframework==7.1.1 \
    robotframework-seleniumlibrary==6.6.1

# Set working directory
WORKDIR /app

# Copy test files
COPY tests/ ./tests/

# Create results directory
RUN mkdir -p results

# Default environment variables (override with docker run -e)
ENV BROWSER=headlesschrome
ENV BASE_URL=https://eventhub.rahulshettyacademy.com

# Run tests
CMD ["python", "-m", "robot", \
     "--outputdir", "results", \
     "--variable", "BROWSER:headlesschrome", \
     "--loglevel", "INFO", \
     "--name", "EventHub E2E Tests", \
     "tests/"]
