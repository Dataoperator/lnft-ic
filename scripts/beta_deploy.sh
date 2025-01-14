#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🚀 Starting Beta Deployment Process${NC}"

# 1. Verify Environment
echo -e "\n${YELLOW}1. Environment Verification${NC}"
dfx --version
node --version
npm --version

# 2. Clean Start
echo -e "\n${YELLOW}2. Clean Environment${NC}"
dfx stop
rm -rf .dfx
dfx start --clean --background

# 3. Deploy Core Functionality (Sequential for Stability)
echo -e "\n${YELLOW}3. Deploying Core Canisters${NC}"

# Deploy and verify Hub (main orchestrator)
echo "Deploying Hub..."
if ! dfx deploy hub; then
    echo -e "${RED}Hub deployment failed${NC}"
    exit 1
fi

# Deploy and verify Neural System
echo "Deploying Neural System..."
if ! dfx deploy neural; then
    echo -e "${RED}Neural System deployment failed${NC}"
    exit 1
fi

# Deploy and verify Memory System
echo "Deploying Memory System..."
if ! dfx deploy memory; then
    echo -e "${RED}Memory System deployment failed${NC}"
    exit 1
fi

# 4. Frontend Deployment
echo -e "\n${YELLOW}4. Frontend Deployment${NC}"
cd src/frontend
npm install
npm run build
cd ../..
dfx deploy frontend

# 5. Core Journey Verification
echo -e "\n${YELLOW}5. Verifying Core User Journey${NC}"

# Get canister IDs
HUB_ID=$(dfx canister id hub)
NEURAL_ID=$(dfx canister id neural)
MEMORY_ID=$(dfx canister id memory)

# Test LNFT Creation
echo "Testing LNFT Creation..."
dfx canister call $HUB_ID create_lnft '()'

# Test Neural Processing
echo "Testing Neural Processing..."
dfx canister call $NEURAL_ID process_emotion '(record { joy = 0.8; trust = 0.7 })'

# Test Memory Formation
echo "Testing Memory Formation..."
dfx canister call $MEMORY_ID create_memory '(record { intensity = 0.9; context = "test" })'

# 6. Health Check
echo -e "\n${YELLOW}6. System Health Verification${NC}"

# Check memory consumption (using IC's built-in metrics)
dfx canister status $HUB_ID
dfx canister status $NEURAL_ID
dfx canister status $MEMORY_ID

# 7. Frontend URL
FRONTEND_ID=$(dfx canister id frontend)
echo -e "\n${GREEN}✅ Beta Deployment Complete!${NC}"
echo -e "Frontend URL: http://localhost:8000?canisterId=$FRONTEND_ID"
echo -e "Hub Canister ID: $HUB_ID"
echo -e "Neural Canister ID: $NEURAL_ID"
echo -e "Memory Canister ID: $MEMORY_ID"

# Monitor logs for initial usage
echo -e "\n${YELLOW}Monitoring system logs for 60 seconds...${NC}"
timeout 60 dfx canister logs $HUB_ID