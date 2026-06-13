#!/bin/bash
# ══════════════════════════════════════════════════════════════════════════════
# Run Robot Framework Tests in Docker
#
# Usage:
#   ./run-tests.sh                    # Run with default credentials
#   ./run-tests.sh -e EMAIL -p PASS   # Run with custom credentials
#   ./run-tests.sh --help             # Show help
# ══════════════════════════════════════════════════════════════════════════════

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
TEST_EMAIL="${TEST_EMAIL:-}"
TEST_PASSWORD="${TEST_PASSWORD:-}"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--email)
            TEST_EMAIL="$2"
            shift 2
            ;;
        -p|--password)
            TEST_PASSWORD="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -e, --email EMAIL      Test account email"
            echo "  -p, --password PASS    Test account password"
            echo "  -h, --help             Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  TEST_EMAIL             Test account email"
            echo "  TEST_PASSWORD          Test account password"
            echo ""
            echo "Examples:"
            echo "  $0 -e user@test.com -p secret123"
            echo "  TEST_EMAIL=user@test.com TEST_PASSWORD=secret123 $0"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Check if credentials are provided
if [[ -z "$TEST_EMAIL" || -z "$TEST_PASSWORD" ]]; then
    echo -e "${YELLOW}⚠️  No credentials provided. Tests requiring login will fail.${NC}"
    echo -e "${YELLOW}   Use: $0 -e EMAIL -p PASSWORD${NC}"
    echo ""
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

echo -e "${GREEN}🐳 Building Docker image...${NC}"
docker build -t eventhub-robot-tests .

echo -e "${GREEN}🤖 Running Robot Framework tests...${NC}"
echo ""

# Create results directory if it doesn't exist
mkdir -p results

# Run tests
docker run --rm \
    -e TEST_EMAIL="${TEST_EMAIL}" \
    -e TEST_PASSWORD="${TEST_PASSWORD}" \
    -e ALT_EMAIL="${ALT_EMAIL:-}" \
    -e ALT_PASSWORD="${ALT_PASSWORD:-}" \
    -v "$(pwd)/results:/app/results" \
    --shm-size=2g \
    eventhub-robot-tests

echo ""
echo -e "${GREEN}✅ Tests completed!${NC}"
echo -e "${GREEN}📊 Reports available at:${NC}"
echo "   - results/report.html"
echo "   - results/log.html"
