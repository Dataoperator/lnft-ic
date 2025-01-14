#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔄 Generating Canister Declarations...${NC}"

# Remove old declarations
rm -rf src/declarations

# Generate new declarations
dfx generate

# Move declarations to typescript directory
mkdir -p src/declarations
mv src/declarations/**/*.ts src/declarations/
mv src/declarations/**/*.js src/declarations/
mv src/declarations/**/*.did src/declarations/

# Clean up empty directories
find src/declarations -type d -empty -delete

echo -e "${GREEN}✅ Declarations generated successfully${NC}"