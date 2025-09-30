#!/bin/bash

# Check which events exist on the contract

echo "Checking events on contract..."
echo "=============================="
echo ""

for i in {1..10}; do
    echo "Event $i:"
    cast call 0x7CF4DA7307AC0213542b6838969058469c412555 \
        "events(uint256)" $i \
        --rpc-url https://eth-sepolia.public.blastapi.io 2>/dev/null | head -3
    echo ""
done
