#!/bin/bash

# Validate .env configuration before deployment

set -e

echo "========================================="
echo "    Validating .env Configuration"
echo "========================================="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "   Run: cp .env.example .env"
    exit 1
fi

# Load environment variables
source .env

# Validation function
validate_var() {
    local var_name=$1
    local var_value=$2
    local var_type=$3
    
    if [ -z "$var_value" ]; then
        echo "❌ $var_name is empty"
        return 1
    fi
    
    if [[ "$var_value" == *"your_"* ]] || [[ "$var_value" == *"_here"* ]]; then
        echo "❌ $var_name contains placeholder value"
        return 1
    fi
    
    if [ "$var_type" == "private_key" ]; then
        if [[ ! "$var_value" =~ ^0x[a-fA-F0-9]{64}$ ]]; then
            if [[ "$var_value" =~ ^[a-fA-F0-9]{64}$ ]]; then
                echo "⚠️  $var_name is missing '0x' prefix - add '0x' at the beginning"
            else
                echo "❌ $var_name is not a valid private key format (needs 64 hex chars with 0x prefix)"
            fi
            return 1
        fi
    fi
    
    if [ "$var_type" == "address" ]; then
        if [[ ! "$var_value" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
            echo "❌ $var_name is not a valid address format"
            return 1
        fi
    fi
    
    if [ "$var_type" == "rpc" ]; then
        if [[ ! "$var_value" =~ ^https?:// ]]; then
            echo "❌ $var_name is not a valid RPC URL"
            return 1
        fi
    fi
    
    echo "✅ $var_name"
    return 0
}

# Validate all required variables
ERROR_COUNT=0

echo "Checking RPC URLs..."
validate_var "ORIGIN_RPC" "$ORIGIN_RPC" "rpc" || ((ERROR_COUNT++))
validate_var "DESTINATION_RPC" "$DESTINATION_RPC" "rpc" || ((ERROR_COUNT++))
validate_var "REACTIVE_RPC" "$REACTIVE_RPC" "rpc" || ((ERROR_COUNT++))
echo ""

echo "Checking Private Keys..."
validate_var "ORIGIN_PRIVATE_KEY" "$ORIGIN_PRIVATE_KEY" "private_key" || ((ERROR_COUNT++))
validate_var "DESTINATION_PRIVATE_KEY" "$DESTINATION_PRIVATE_KEY" "private_key" || ((ERROR_COUNT++))
validate_var "REACTIVE_PRIVATE_KEY" "$REACTIVE_PRIVATE_KEY" "private_key" || ((ERROR_COUNT++))
echo ""

echo "Checking System Contracts..."
validate_var "SYSTEM_CONTRACT_ADDR" "$SYSTEM_CONTRACT_ADDR" "address" || ((ERROR_COUNT++))
validate_var "DESTINATION_CALLBACK_PROXY_ADDR" "$DESTINATION_CALLBACK_PROXY_ADDR" "address" || ((ERROR_COUNT++))
echo ""

echo "Checking Chain IDs..."
validate_var "ORIGIN_CHAIN_ID" "$ORIGIN_CHAIN_ID" "number" || ((ERROR_COUNT++))
validate_var "DESTINATION_CHAIN_ID" "$DESTINATION_CHAIN_ID" "number" || ((ERROR_COUNT++))
validate_var "REACTIVE_CHAIN_ID" "$REACTIVE_CHAIN_ID" "number" || ((ERROR_COUNT++))
echo ""

# Test RPC connectivity
echo "Testing RPC connectivity..."

test_rpc() {
    local name=$1
    local rpc=$2
    
    if timeout 5 cast block-number --rpc-url "$rpc" &> /dev/null; then
        echo "✅ $name is reachable"
        return 0
    else
        echo "⚠️  $name is not reachable (this may be okay if the chain is down)"
        return 1
    fi
}

test_rpc "Origin RPC (Sepolia)" "$ORIGIN_RPC"
test_rpc "Destination RPC (Sepolia)" "$DESTINATION_RPC"
test_rpc "Reactive RPC (Kopli)" "$REACTIVE_RPC"
echo ""

# Check balances
echo "Checking account balances..."

check_balance() {
    local name=$1
    local rpc=$2
    local key=$3
    
    # Derive address from private key
    local address=$(cast wallet address "$key" 2>/dev/null || echo "")
    
    if [ -z "$address" ]; then
        echo "⚠️  $name: Could not derive address from private key"
        return 1
    fi
    
    local balance=$(cast balance "$address" --rpc-url "$rpc" 2>/dev/null || echo "0")
    
    if [ "$balance" == "0" ]; then
        echo "⚠️  $name ($address): 0 ETH - You need testnet tokens!"
        return 1
    else
        local eth_balance=$(cast --to-unit "$balance" ether 2>/dev/null || echo "0")
        echo "✅ $name ($address): $eth_balance ETH"
        return 0
    fi
}

check_balance "Origin Chain" "$ORIGIN_RPC" "$ORIGIN_PRIVATE_KEY"
check_balance "Destination Chain" "$DESTINATION_RPC" "$DESTINATION_PRIVATE_KEY"
check_balance "Reactive Network" "$REACTIVE_RPC" "$REACTIVE_PRIVATE_KEY"
echo ""

# Final summary
echo "========================================="
if [ $ERROR_COUNT -eq 0 ]; then
    echo "✅ Configuration is valid!"
    echo "   You can now run: ./deploy.sh"
else
    echo "❌ Found $ERROR_COUNT configuration errors"
    echo "   Please fix them before deploying"
    exit 1
fi
echo "========================================="
