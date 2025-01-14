#!/bin/bash

# Generate canister declarations
echo "Generating canister declarations..."
dfx generate

# Fix unused imports
echo "Fixing unused imports..."
find src -name "*.ts" -o -name "*.tsx" | while read -r file; do
  # Remove unused imports
  sed -i 's/import { Memory,/import {/g' "$file"
  sed -i 's/import { Trait,/import {/g' "$file"
  sed -i 's/import { LNFT,/import {/g' "$file"
  sed -i 's/, ActorSubclass//g' "$file"
done

# Fix void truthiness check
echo "Fixing void truthiness check..."
sed -i 's/if (!success)/if (success === false)/g' src/features/auth/auth.store.ts

echo "TypeScript fixes applied!"