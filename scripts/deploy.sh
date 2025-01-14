#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

NETWORK=$1
echo -e "${YELLOW}🚀 Starting deployment process for network: ${NETWORK}${NC}"

# Clean build
echo -e "${YELLOW}🧹 Cleaning previous build...${NC}"
npm run clean

# Generate declarations
echo -e "${YELLOW}📝 Generating declarations...${NC}"
./scripts/generate-declarations.sh

# Start dfx if needed
if [ "$NETWORK" = "local" ]; then
    echo -e "${YELLOW}🔍 Finding available port...${NC}"
    PORT=8000
    while netstat -tuln | grep -q ":$PORT "; do
        ((PORT++))
    done
    jq ".networks.local.bind = \"127.0.0.1:$PORT\"" dfx.json > dfx.json.tmp && mv dfx.json.tmp dfx.json
    echo "Updated dfx.json to use port $PORT"

    echo -e "${YELLOW}🔄 Starting dfx (attempt 1/3)...${NC}"
    attempts=0
    max_attempts=3
    while [ $attempts -lt $max_attempts ]; do
        if dfx start --clean --background; then
            echo -e "${GREEN}DFX started successfully!${NC}"
            break
        else
            ((attempts++))
            if [ $attempts -eq $max_attempts ]; then
                echo -e "${RED}Failed to start DFX after $max_attempts attempts${NC}"
                exit 1
            fi
            echo -e "${YELLOW}Retrying... (attempt $((attempts + 1))/$max_attempts)${NC}"
            sleep 2
        fi
    done
fi

# Install dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
npm install

# Build project
echo -e "${YELLOW}🏗️ Building project...${NC}"
dfx build

# Deploy based on network
if [ "$NETWORK" = "local" ]; then
    dfx canister install --all --mode=reinstall
elif [ "$NETWORK" = "ic" ]; then
    dfx deploy --network ic
else
    echo -e "${RED}Invalid network specified${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Deployment complete!${NC}"