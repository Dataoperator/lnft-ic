#!/bin/bash

# Run the Node.js script to update the port
node scripts/update-port.js

# Check if the script succeeded
if [ $? -eq 0 ]; then
    echo "Successfully updated dfx.json with new port"
    exit 0
else
    echo "Failed to update dfx.json"
    exit 1
fi