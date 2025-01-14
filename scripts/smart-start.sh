#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔍 Smart Start Script Initializing...${NC}"

# Function to find an available port
find_available_port() {
    local port=8000
    while netstat -tuln | grep -q ":$port "; do
        ((port++))
    done
    echo $port
}

# Function to check if dfx is running
is_dfx_running() {
    if pgrep -x "dfx" > /dev/null; then
        return 0 # true
    else
        return 1 # false
    fi
}

# Function to safely stop dfx
stop_dfx() {
    echo -e "${YELLOW}🛑 Stopping DFX processes...${NC}"
    dfx stop
    # Kill any remaining dfx processes
    pkill -f dfx
    sleep 2
}

# Function to update dfx.json with new port
update_dfx_port() {
    local port=$1
    echo -e "${YELLOW}📝 Updating dfx.json with port: $port${NC}"
    # Use temporary file to avoid potential race conditions
    jq ".networks.local.bind = \"127.0.0.1:$port\"" dfx.json > dfx.json.tmp && mv dfx.json.tmp dfx.json
    echo -e "${GREEN}✅ Successfully updated dfx.json${NC}"
}

# Function to clean build artifacts
clean_build() {
    echo -e "${YELLOW}🧹 Cleaning previous build artifacts...${NC}"
    rm -rf .dfx dist src/frontend/dist
    echo -e "${GREEN}✅ Clean complete${NC}"
}

# Main execution
main() {
    # 1. Stop any running dfx instances
    if is_dfx_running; then
        echo -e "${YELLOW}⚠️  Existing DFX process detected${NC}"
        stop_dfx
    fi

    # 2. Clean build artifacts
    clean_build

    # 3. Find available port
    PORT=$(find_available_port)
    echo -e "${GREEN}✅ Found available port: $PORT${NC}"

    # 4. Update dfx.json
    update_dfx_port $PORT

    # 5. Start dfx
    echo -e "${YELLOW}🚀 Starting DFX...${NC}"
    dfx start --clean --background
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to start DFX${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ DFX started successfully${NC}"

    # 6. Deploy local
    echo -e "${YELLOW}📦 Deploying canisters...${NC}"
    npm run deploy:local
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Deployment failed${NC}"
        stop_dfx
        exit 1
    fi

    # 7. Start development server
    echo -e "${YELLOW}🌐 Starting development server...${NC}"
    npm run dev
}

# Error handling
set -e
trap 'echo -e "${RED}❌ Error occurred. Cleaning up...${NC}"; stop_dfx; exit 1' ERR

# Execute main function
main