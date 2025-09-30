#!/bin/bash

# Complete deployment script using forge script (more reliable than forge create)

set -e

echo "========================================"
echo "   A10D Event Ticketing Deployment"
echo "     (Using Forge Script Method)"
echo "========================================"
echo ""

# Load environment variables
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    exit 1
fi

source .env

# Step 1: Deploy TicketCallback to destination chain (Sepolia)
echo "Step 1: Deploying TicketCallback to destination chain (Sepolia)..."
echo "  RPC: $DESTINATION_RPC"
echo ""

CALLBACK_OUTPUT=$(forge script script/DeployCallback.s.sol:DeployCallback \
    --rpc-url "$DESTINATION_RPC" \
    --private-key "$DESTINATION_PRIVATE_KEY" \
    --broadcast 2>&1)

CALLBACK_ADDR=$(echo "$CALLBACK_OUTPUT" | grep "TicketCallback deployed to:" | grep -oE "0x[a-fA-F0-9]{40}")

if [ -z "$CALLBACK_ADDR" ]; then
    echo "❌ Failed to deploy TicketCallback"
    echo "$CALLBACK_OUTPUT"
    exit 1
fi

echo "✅ TicketCallback deployed at: $CALLBACK_ADDR"
echo ""

# Step 2: Deploy EventTicket to origin chain (Sepolia)
echo "Step 2: Deploying EventTicket to origin chain (Sepolia)..."
echo "  RPC: $ORIGIN_RPC"
echo ""

TICKET_OUTPUT=$(forge script script/DeployEventTicket.s.sol:DeployEventTicket \
    --rpc-url "$ORIGIN_RPC" \
    --private-key "$ORIGIN_PRIVATE_KEY" \
    --broadcast 2>&1)

TICKET_ADDR=$(echo "$TICKET_OUTPUT" | grep "EventTicket deployed to:" | grep -oE "0x[a-fA-F0-9]{40}")

if [ -z "$TICKET_ADDR" ]; then
    echo "❌ Failed to deploy EventTicket"
    echo "$TICKET_OUTPUT"
    exit 1
fi

echo "✅ EventTicket deployed at: $TICKET_ADDR"
echo ""

# Step 3: Update .env with deployed addresses for reactive validator
echo "Step 3: Preparing TicketReactiveValidator deployment..."
echo "  Updating .env with deployed addresses..."

# Backup .env
cp .env .env.backup-$(date +%s)

# Update .env file
sed -i.tmp "s|^EVENT_TICKET_ADDR=.*|EVENT_TICKET_ADDR=$TICKET_ADDR|" .env
sed -i.tmp "s|^TICKET_CALLBACK_ADDR=.*|TICKET_CALLBACK_ADDR=$CALLBACK_ADDR|" .env
rm -f .env.tmp

echo "✅ .env updated"
echo ""

# Step 4: Deploy TicketReactiveValidator to Reactive Network
echo "Step 4: Deploying TicketReactiveValidator to Reactive Network (Lasna)..."
echo "  RPC: $REACTIVE_RPC"
echo ""

REACTIVE_OUTPUT=$(forge script script/DeployReactiveValidator.s.sol:DeployReactiveValidator \
    --rpc-url "$REACTIVE_RPC" \
    --private-key "$REACTIVE_PRIVATE_KEY" \
    --broadcast 2>&1)

REACTIVE_ADDR=$(echo "$REACTIVE_OUTPUT" | grep "TicketReactiveValidator deployed to:" | grep -oE "0x[a-fA-F0-9]{40}")

if [ -z "$REACTIVE_ADDR" ]; then
    echo "❌ Failed to deploy TicketReactiveValidator"
    echo "$REACTIVE_OUTPUT"
    exit 1
fi

echo "✅ TicketReactiveValidator deployed at: $REACTIVE_ADDR"
echo ""

# Update .env with reactive validator address
sed -i.tmp "s|^TICKET_REACTIVE_ADDR=.*|TICKET_REACTIVE_ADDR=$REACTIVE_ADDR|" .env
rm -f .env.tmp

# Summary
echo "========================================"
echo "       ✅ Deployment Complete! ✅"
echo "========================================"
echo ""
echo "📍 Origin Chain (Sepolia - Chain ID: $ORIGIN_CHAIN_ID)"
echo "   EventTicket: $TICKET_ADDR"
echo "   View: https://sepolia.etherscan.io/address/$TICKET_ADDR"
echo ""
echo "📍 Destination Chain (Sepolia - Chain ID: $DESTINATION_CHAIN_ID)"
echo "   TicketCallback: $CALLBACK_ADDR"
echo "   View: https://sepolia.etherscan.io/address/$CALLBACK_ADDR"
echo ""
echo "📍 Reactive Network (Lasna - Chain ID: $REACTIVE_CHAIN_ID)"
echo "   TicketReactiveValidator: $REACTIVE_ADDR"
echo "   View: https://lasna.reactscan.net/address/$REACTIVE_ADDR"
echo ""
echo "✅ All addresses saved to .env file"
echo ""
echo "Next steps:"
echo "  1. Verify contracts on block explorers"
echo "  2. Test the system: ./scripts/interact.sh create-event"
echo ""
echo "🎉 Deployment successful!"
