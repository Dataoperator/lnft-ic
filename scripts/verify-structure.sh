#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Verifying project structure..."

# Check required directories
required_dirs=(
    "src/frontend"
    "src/lnft_core"
    "src/auth"
    "src/cronolink"
    ".dfx"
    "src/frontend/dist"
)

# Check required files
required_files=(
    "dfx.json"
    "package.json"
    "src/lnft_core/main.mo"
    "src/auth/main.mo"
    "src/cronolink/main.mo"
)

# Check Motoko declarations
required_declarations=(
    ".dfx/local/canisters/lnft_core/lnft_core.did.js"
    ".dfx/local/canisters/auth/auth.did.js"
    ".dfx/local/canisters/cronolink/cronolink.did.js"
)

missing_items=0

# Check directories
echo -e "\n📁 Checking directories..."
for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        echo -e "${RED}❌ Missing directory: $dir${NC}"
        missing_items=$((missing_items + 1))
    else
        echo -e "${GREEN}✓ Found directory: $dir${NC}"
    fi
done

# Check files
echo -e "\n📄 Checking files..."
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Missing file: $file${NC}"
        missing_items=$((missing_items + 1))
    else
        echo -e "${GREEN}✓ Found file: $file${NC}"
    fi
done

# Check if dfx is running
echo -e "\n🔄 Checking DFX status..."
if ! dfx ping; then
    echo -e "${YELLOW}⚠️  DFX is not running. Starting DFX...${NC}"
    dfx start --background
fi

# Generate declarations if needed
echo -e "\n🔄 Checking declarations..."
if [ ! -d ".dfx/local/canisters" ]; then
    echo -e "${YELLOW}⚠️  Declarations not found. Generating...${NC}"
    dfx generate
fi

# Final report
echo -e "\n📊 Verification Report:"
if [ $missing_items -eq 0 ]; then
    echo -e "${GREEN}✅ All required items are present${NC}"
else
    echo -e "${RED}❌ Missing $missing_items required items${NC}"
fi

# Check node_modules
echo -e "\n📦 Checking node dependencies..."
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}⚠️  node_modules not found. Installing dependencies...${NC}"
    npm install
fi

# Verify frontend build
echo -e "\n🏗️  Testing frontend build..."
if npm run build; then
    echo -e "${GREEN}✅ Frontend build successful${NC}"
else
    echo -e "${RED}❌ Frontend build failed${NC}"
    exit 1
fi

exit $missing_items