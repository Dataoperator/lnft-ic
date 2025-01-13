#!/bin/bash

# Exit on error
set -e

echo "Starting deployment process..."

# Check dfx version
dfx --version

# Build and optimize frontend
echo "Building frontend..."
cd src/frontend
npm install
npm run build
cd ../..

# Check canister status
echo "Checking canister status..."
dfx canister status || true

# Deploy with best practices
echo "Deploying canisters..."
dfx deploy --network ic \
    --argument "(null)" \
    --with-cycles 2000000000000 \
    --yes

# Verify deployment
echo "Verifying deployment..."
dfx canister status --network ic

echo "Deployment complete! Canister IDs:"
dfx canister id --network ic lnft_core
dfx canister id --network ic auth
dfx canister id --network ic cronolink
dfx canister id --network ic frontend

# Optional: Print frontend URL
echo "Frontend URL: https://$(dfx canister id --network ic frontend).raw.ic0.app/"