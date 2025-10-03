#!/bin/bash

# Script to generate coverage badge
# Usage: ./coverage_badge.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running tests with coverage...${NC}"

# Run tests with coverage
flutter test --coverage

# Check if coverage directory exists
if [ ! -d "coverage" ]; then
    echo -e "${RED}Coverage directory not found!${NC}"
    exit 1
fi

# Generate HTML coverage report
echo -e "${YELLOW}Generating HTML coverage report...${NC}"
genhtml coverage/lcov.info -o coverage/html

# Extract coverage percentage
COVERAGE=$(lcov --summary coverage/lcov.info | grep -o '[0-9.]*%' | head -1 | sed 's/%//')

echo -e "${GREEN}Coverage: ${COVERAGE}%${NC}"

# Generate badge based on coverage
if (( $(echo "$COVERAGE >= 90" | bc -l) )); then
    BADGE_COLOR="brightgreen"
elif (( $(echo "$COVERAGE >= 80" | bc -l) )); then
    BADGE_COLOR="green"
elif (( $(echo "$COVERAGE >= 70" | bc -l) )); then
    BADGE_COLOR="yellow"
elif (( $(echo "$COVERAGE >= 60" | bc -l) )); then
    BADGE_COLOR="orange"
else
    BADGE_COLOR="red"
fi

# Create badge URL
BADGE_URL="https://img.shields.io/badge/coverage-${COVERAGE}%25-${BADGE_COLOR}"

echo -e "${GREEN}Coverage badge URL: ${BADGE_URL}${NC}"

# Save coverage percentage to file for CI
echo "${COVERAGE}" > coverage_percentage.txt

echo -e "${GREEN}Coverage report generated successfully!${NC}"
echo -e "${YELLOW}HTML report available at: coverage/html/index.html${NC}"
