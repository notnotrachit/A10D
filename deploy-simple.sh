#!/bin/bash

# Simple deployment using forge script instead of forge create

set -e

echo "========================================"
echo "   A10D Event Ticketing Deployment"
echo "========================================"
echo ""

# Load environment variables
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    exit 1
fi

source .env

# Deploy using forge script
echo "Step 1: Deploying TicketCallback to destination chain..."
echo "  RPC: $DESTINATION_RPC"
echo ""

forge script script/DeployCallback.s.sol:DeployCallback \
    --rpc-url "$DESTINATION_RPC" \
    --private-key "$DESTINATION_PRIVATE_KEY" \
    --broadcast \
    -vvv

echo ""
echo "Deployment complete! Check the output above for deployed addresses."
echo ""
