#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting MVP build process...${NC}"

# Stop any running dfx instance
echo -e "${YELLOW}Stopping dfx...${NC}"
dfx stop

# Clean up
echo -e "${YELLOW}Cleaning up previous build...${NC}"
rm -rf .dfx
rm -rf src/frontend/dist
rm -rf src/declarations

# Start dfx
echo -e "${YELLOW}Starting dfx...${NC}"
dfx start --clean --background

# Build and deploy canisters in sequence
echo -e "${YELLOW}Deploying canisters...${NC}"

# Deploy auth first
echo -e "${YELLOW}Deploying auth canister...${NC}"
dfx deploy auth
if [ $? -ne 0 ]; then
    echo -e "${RED}Auth canister deployment failed${NC}"
    exit 1
fi

# Deploy core next
echo -e "${YELLOW}Deploying LNFT core canister...${NC}"
dfx deploy lnft_core
if [ $? -ne 0 ]; then
    echo -e "${RED}LNFT core deployment failed${NC}"
    exit 1
fi

# Deploy memory system
echo -e "${YELLOW}Deploying memory system...${NC}"
dfx deploy memory_system
if [ $? -ne 0 ]; then
    echo -e "${RED}Memory system deployment failed${NC}"
    exit 1
fi

# Deploy traits
echo -e "${YELLOW}Deploying traits system...${NC}"
dfx deploy traits
if [ $? -ne 0 ]; then
    echo -e "${RED}Traits system deployment failed${NC}"
    exit 1
fi

# Generate declarations
echo -e "${YELLOW}Generating declarations...${NC}"
dfx generate
if [ $? -ne 0 ]; then
    echo -e "${RED}Declaration generation failed${NC}"
    exit 1
fi

# Setup frontend
echo -e "${YELLOW}Setting up frontend...${NC}"
cd src/frontend

# Install dependencies
echo -e "${YELLOW}Installing frontend dependencies...${NC}"
npm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Frontend dependency installation failed${NC}"
    exit 1
fi

# Build frontend
echo -e "${YELLOW}Building frontend...${NC}"
npm run build
if [ $? -ne 0 ]; then
    echo -e "${RED}Frontend build failed${NC}"
    exit 1
fi

cd ../..

# Deploy frontend assets
echo -e "${YELLOW}Deploying frontend...${NC}"
dfx deploy frontend
if [ $? -ne 0 ]; then
    echo -e "${RED}Frontend deployment failed${NC}"
    exit 1
fi

echo -e "${GREEN}MVP build completed successfully!${NC}"
echo -e "${YELLOW}Local frontend URL: http://127.0.0.1:8000/?canisterId=$(dfx canister id frontend)${NC}"