#!/bin/bash

# Quick fix for .env file - updates system contract addresses with correct checksum

if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    exit 1
fi

# Backup existing .env
cp .env .env.backup
echo "✅ Created backup: .env.backup"

# Fix the checksummed addresses
sed -i.tmp 's/SYSTEM_CONTRACT_ADDR=0x0000000000000000000000000000000000FFFFFF/SYSTEM_CONTRACT_ADDR=0x0000000000000000000000000000000000fffFfF/g' .env
sed -i.tmp 's/DESTINATION_CALLBACK_PROXY_ADDR=0x0000000000000000000000000000000000FFFFFF/DESTINATION_CALLBACK_PROXY_ADDR=0x0000000000000000000000000000000000fffFfF/g' .env

# Remove temp file
rm -f .env.tmp

echo "✅ Fixed system contract addresses in .env"
echo ""
echo "Updated addresses:"
grep "SYSTEM_CONTRACT_ADDR\|CALLBACK_PROXY_ADDR" .env
echo ""
echo "Run ./deploy.sh to deploy!"
