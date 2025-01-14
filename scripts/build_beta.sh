#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}=== LNFT Platform Beta Build Process ===${NC}"

# Function to handle errors
handle_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

# Function to deploy canister
deploy_canister() {
    echo -e "${YELLOW}Deploying $1 canister...${NC}"
    dfx deploy $1 || handle_error "$1 deployment failed"
    echo -e "${GREEN}✓ $1 deployed successfully${NC}"
}

# Clean up
echo -e "${YELLOW}Cleaning up previous build...${NC}"
dfx stop
rm -rf .dfx
rm -rf src/frontend/dist
rm -rf src/declarations

# Start dfx
echo -e "${YELLOW}Starting Internet Computer replica...${NC}"
dfx start --clean --background || handle_error "Failed to start dfx"

# Deploy core systems in order
echo -e "${CYAN}=== Deploying Core Systems ===${NC}"

# 1. Deploy LNFT Core (Hub)
deploy_canister "lnft_core"

# 2. Deploy Auth System
deploy_canister "auth"

# 3. Deploy Cronolink (Neural Interface)
deploy_canister "cronolink"

# 4. Deploy Memory System
deploy_canister "memory_system"

# 5. Deploy Supporting Systems
echo -e "${CYAN}=== Deploying Supporting Systems ===${NC}"
deploy_canister "traits"
deploy_canister "skill_library"

# Generate declarations
echo -e "${YELLOW}Generating canister declarations...${NC}"
dfx generate || handle_error "Declaration generation failed"

# Copy declarations to frontend
echo -e "${YELLOW}Setting up frontend declarations...${NC}"
mkdir -p src/frontend/src/declarations
cp -r src/declarations/* src/frontend/src/declarations/

# Frontend setup
echo -e "${CYAN}=== Setting up Frontend ===${NC}"
cd src/frontend || handle_error "Frontend directory not found"

# Install dependencies
echo -e "${YELLOW}Installing frontend dependencies...${NC}"
npm install || handle_error "Frontend dependency installation failed"

# Build frontend
echo -e "${YELLOW}Building frontend...${NC}"
npm run build || handle_error "Frontend build failed"

cd ../..

# Deploy frontend assets
echo -e "${YELLOW}Deploying frontend assets...${NC}"
dfx deploy frontend || handle_error "Frontend deployment failed"

# Final checks
echo -e "${CYAN}=== Performing Final Checks ===${NC}"

# Get canister IDs
FRONTEND_ID=$(dfx canister id frontend)
LNFT_CORE_ID=$(dfx canister id lnft_core)
CRONOLINK_ID=$(dfx canister id cronolink)

# Update environment variables
echo -e "${YELLOW}Updating environment configuration...${NC}"
cat > src/frontend/.env.development << EOL
VITE_DFX_NETWORK=local
VITE_IC_HOST=http://127.0.0.1:8000
VITE_INTERNET_IDENTITY_URL=https://identity.ic0.app
VITE_LNFT_CORE_CANISTER_ID=${LNFT_CORE_ID}
VITE_AUTH_CANISTER_ID=$(dfx canister id auth)
VITE_CRONOLINK_CANISTER_ID=${CRONOLINK_ID}
EOL

echo -e "${GREEN}=== Beta Build Complete! ===${NC}"
echo -e "${CYAN}Frontend URL: http://127.0.0.1:8000/?canisterId=${FRONTEND_ID}${NC}"
echo -e "${CYAN}LNFT Core Canister ID: ${LNFT_CORE_ID}${NC}"
echo -e "${CYAN}Cronolink Canister ID: ${CRONOLINK_ID}${NC}"

# Print next steps
echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "1. Start frontend development server: ${CYAN}cd src/frontend && npm run dev${NC}"
echo -e "2. Access Candid interface: ${CYAN}http://127.0.0.1:8000/?canisterId=${LNFT_CORE_ID}&id=${LNFT_CORE_ID}${NC}"
echo -e "3. Monitor dfx output: ${CYAN}dfx canister status lnft_core${NC}"