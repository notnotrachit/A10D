#!/bin/bash

# Test multiple Sepolia RPC endpoints to find the fastest working one

echo "Testing Sepolia RPC Endpoints..."
echo "================================="
echo ""

SEPOLIA_RPCS=(
    "https://eth-sepolia.public.blastapi.io"
    "https://api.zan.top/eth-sepolia"
    "https://0xrpc.io/sep"
    "https://rpc.sepolia.org"
    "https://rpc2.sepolia.org"
    "https://ethereum-sepolia-rpc.publicnode.com"
    "https://sepolia.gateway.tenderly.co"
)

REACTIVE_RPCS=(
    "https://lasna-rpc.rnk.dev/"
    "https://kopli-rpc.rkt.ink"
)

test_rpc() {
    local url=$1
    echo -n "Testing $url ... "
    
    if timeout 5 cast block-number --rpc-url "$url" &> /dev/null; then
        local block=$(cast block-number --rpc-url "$url" 2>/dev/null)
        echo "✅ Working (Block: $block)"
        return 0
    else
        echo "❌ Failed"
        return 1
    fi
}

echo "Sepolia RPC Endpoints:"
echo "----------------------"
WORKING_SEPOLIA=""
for rpc in "${SEPOLIA_RPCS[@]}"; do
    if test_rpc "$rpc"; then
        if [ -z "$WORKING_SEPOLIA" ]; then
            WORKING_SEPOLIA="$rpc"
        fi
    fi
done
echo ""

echo "Reactive Kopli RPC Endpoints:"
echo "-----------------------------"
WORKING_REACTIVE=""
for rpc in "${REACTIVE_RPCS[@]}"; do
    if test_rpc "$rpc"; then
        WORKING_REACTIVE="$rpc"
    fi
done
echo ""

echo "================================="
echo "Recommendation:"
echo "================================="
if [ -n "$WORKING_SEPOLIA" ]; then
    echo "Use this in your .env for ORIGIN_RPC and DESTINATION_RPC:"
    echo "  $WORKING_SEPOLIA"
    echo ""
else
    echo "⚠️  No working Sepolia RPC found. Try again later or use Alchemy/Infura."
    echo ""
fi

if [ -n "$WORKING_REACTIVE" ]; then
    echo "Use this in your .env for REACTIVE_RPC:"
    echo "  $WORKING_REACTIVE"
else
    echo "⚠️  Reactive Kopli RPC is not responding. Check network status."
fi
echo ""
