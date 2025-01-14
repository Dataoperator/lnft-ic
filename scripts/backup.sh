#!/bin/bash

# Backup script for Internet Computer project
set -e

# Configuration
BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_${TIMESTAMP}"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to backup canister state
backup_canister() {
    local canister=$1
    local network=${2:-local}
    
    echo "📦 Backing up $canister canister..."
    
    # Create backup directory for this canister
    mkdir -p "$BACKUP_DIR/$BACKUP_NAME/$canister"
    
    # Export canister state
    dfx canister --network "$network" export "$canister" > "$BACKUP_DIR/$BACKUP_NAME/$canister/state.cbor" 2>/dev/null || true
    
    # Backup relevant source files
    cp -r "src/$canister" "$BACKUP_DIR/$BACKUP_NAME/$canister/src" 2>/dev/null || true
}

# Backup configuration files
backup_config() {
    echo "📝 Backing up configuration files..."
    mkdir -p "$BACKUP_DIR/$BACKUP_NAME/config"
    
    # Configuration files
    cp dfx.json "$BACKUP_DIR/$BACKUP_NAME/config/" 2>/dev/null || true
    cp package.json "$BACKUP_DIR/$BACKUP_NAME/config/" 2>/dev/null || true
    cp vessel.dhall "$BACKUP_DIR/$BACKUP_NAME/config/" 2>/dev/null || true
    cp package-lock.json "$BACKUP_DIR/$BACKUP_NAME/config/" 2>/dev/null || true
    
    # Environment files if they exist
    cp .env* "$BACKUP_DIR/$BACKUP_NAME/config/" 2>/dev/null || true
}

# Main backup process
main() {
    local network=${1:-local}
    
    echo "🔄 Starting backup process for network: $network"
    
    # Backup each canister
    backup_canister "lnft_core" "$network"
    backup_canister "auth" "$network"
    backup_canister "cronolink" "$network"
    backup_canister "frontend" "$network"
    
    # Backup configuration
    backup_config
    
    # Create archive
    echo "📚 Creating archive..."
    cd "$BACKUP_DIR"
    tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
    rm -rf "$BACKUP_NAME"
    
    echo -e "${GREEN}✅ Backup completed successfully!${NC}"
    echo "📍 Backup location: $BACKUP_DIR/${BACKUP_NAME}.tar.gz"
}

# Parse arguments
NETWORK=${1:-local}

# Execute main function
main "$NETWORK"