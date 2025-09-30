#!/bin/bash

# A10D Event Ticketing Deployment Script
# This script automates the deployment of all contracts

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

# Verify required variables
if [ -z "$DESTINATION_RPC" ] || [ -z "$DESTINATION_PRIVATE_KEY" ] || [ -z "$DESTINATION_CALLBACK_PROXY_ADDR" ]; then
    echo "❌ Error: Missing required environment variables"
    echo "   Run: ./validate-env.sh to check your configuration"
    exit 1
fi

# Step 1: Deploy TicketCallback to destination chain
echo "Step 1: Deploying TicketCallback to destination chain..."
echo "  RPC: $DESTINATION_RPC"
echo "  Constructor arg: $DESTINATION_CALLBACK_PROXY_ADDR"
echo ""

CALLBACK_OUTPUT=$(forge create \
    src/TicketCallback.sol:TicketCallback \
    --rpc-url "$DESTINATION_RPC" \
    --private-key "$DESTINATION_PRIVATE_KEY" \
    --constructor-args "$DESTINATION_CALLBACK_PROXY_ADDR" \
    --broadcast 2>&1)

# Extract deployed address from output
CALLBACK_ADDR=$(echo "$CALLBACK_OUTPUT" | grep -oE "Deployed to: 0x[a-fA-F0-9]{40}" | grep -oE "0x[a-fA-F0-9]{40}")

if [ -z "$CALLBACK_ADDR" ]; then
    echo "❌ Failed to deploy TicketCallback"
    echo "$CALLBACK_OUTPUT"
    exit 1
fi

echo "✓ TicketCallback deployed at: $CALLBACK_ADDR"
echo ""

# Step 2: Deploy EventTicket to origin chain
echo "Step 2: Deploying EventTicket to origin chain..."
echo "  RPC: $ORIGIN_RPC"
echo ""

TICKET_OUTPUT=$(forge create \
    src/EventTicket.sol:EventTicket \
    --rpc-url "$ORIGIN_RPC" \
    --private-key "$ORIGIN_PRIVATE_KEY" \
    --broadcast 2>&1)

# Extract deployed address from output
TICKET_ADDR=$(echo "$TICKET_OUTPUT" | grep -oE "Deployed to: 0x[a-fA-F0-9]{40}" | grep -oE "0x[a-fA-F0-9]{40}")

if [ -z "$TICKET_ADDR" ]; then
    echo "❌ Failed to deploy EventTicket"
    echo "$TICKET_OUTPUT"
    exit 1
fi

echo "✓ EventTicket deployed at: $TICKET_ADDR"
echo ""

# Step 3: Deploy TicketReactiveValidator to Reactive Network
echo "Step 3: Deploying TicketReactiveValidator to Reactive Network..."
echo "  RPC: $REACTIVE_RPC"
echo "  System contract: $SYSTEM_CONTRACT_ADDR"
echo "  Origin chain: $ORIGIN_CHAIN_ID"
echo "  Destination chain: $DESTINATION_CHAIN_ID"
echo "  EventTicket: $TICKET_ADDR"
echo "  TicketCallback: $CALLBACK_ADDR"
echo ""

REACTIVE_OUTPUT=$(forge create \
    src/TicketReactiveValidator.sol:TicketReactiveValidator \
    --rpc-url "$REACTIVE_RPC" \
    --private-key "$REACTIVE_PRIVATE_KEY" \
    --value 0.05ether \
    --constructor-args "$SYSTEM_CONTRACT_ADDR" "$ORIGIN_CHAIN_ID" "$DESTINATION_CHAIN_ID" "$TICKET_ADDR" "$CALLBACK_ADDR" \
    --broadcast 2>&1)

# Extract deployed address from output
REACTIVE_ADDR=$(echo "$REACTIVE_OUTPUT" | grep -oE "Deployed to: 0x[a-fA-F0-9]{40}" | grep -oE "0x[a-fA-F0-9]{40}")

if [ -z "$REACTIVE_ADDR" ]; then
    echo "❌ Failed to deploy TicketReactiveValidator"
    echo "$REACTIVE_OUTPUT"
    exit 1
fi

echo "✓ TicketReactiveValidator deployed at: $REACTIVE_ADDR"
echo ""

# Summary
echo "========================================"
echo "         Deployment Summary"
echo "========================================"
echo ""
echo "Origin Chain (Chain ID: $ORIGIN_CHAIN_ID)"
echo "  EventTicket: $TICKET_ADDR"
echo ""
echo "Destination Chain (Chain ID: $DESTINATION_CHAIN_ID)"
echo "  TicketCallback: $CALLBACK_ADDR"
echo ""
echo "Reactive Network"
echo "  TicketReactiveValidator: $REACTIVE_ADDR"
echo ""
echo "Add these to your .env file:"
echo "EVENT_TICKET_ADDR=$TICKET_ADDR"
echo "TICKET_CALLBACK_ADDR=$CALLBACK_ADDR"
echo "TICKET_REACTIVE_ADDR=$REACTIVE_ADDR"
echo ""
echo "Deployment complete! 🎉"
