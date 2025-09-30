# RPC Setup Guide

## Problem: Public RPC endpoints are unreliable

Public RPC endpoints often have rate limits or timeouts. For reliable deployment, use a dedicated RPC provider.

## Solution: Use Alchemy (Free)

### Step 1: Create Alchemy Account

1. Go to https://www.alchemy.com/
2. Click **"Sign Up"** (top right)
3. Create a free account

### Step 2: Create Sepolia App

1. Click **"+ Create new app"**
2. Fill in:
   - **Chain**: Ethereum
   - **Network**: Sepolia (testnet)
   - **Name**: "A10D Event Ticketing"
3. Click **"Create app"**

### Step 3: Get Your RPC URL

1. Click **"View key"** on your app
2. Copy the **HTTPS** URL (looks like: `https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY`)

### Step 4: Update .env

```bash
# Replace in your .env file:
ORIGIN_RPC=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
DESTINATION_RPC=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
```

## Alternative: Use Infura

### Step 1: Create Infura Account

1. Go to https://infura.io/
2. Sign up for free account

### Step 2: Create API Key

1. Click **"Create New Key"**
2. Select **Web3 API**
3. Name it "A10D"
4. Click **"Create"**

### Step 3: Get Sepolia Endpoint

1. Click on your API key
2. Under **Endpoints**, select **Sepolia**
3. Copy the HTTPS URL

### Step 4: Update .env

```bash
ORIGIN_RPC=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
DESTINATION_RPC=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
```

## For Reactive Network (Kopli)

The Reactive Network RPC might be temporarily down. Try:

1. Check status: https://dev.reactive.network/docs/kopli-testnet
2. Join Discord: https://discord.gg/reactive-network
3. Alternative RPC (if provided in docs)

## Quick Test

After updating your `.env`, test the connection:

```bash
# Test Sepolia
cast block-number --rpc-url "$ORIGIN_RPC"

# Test Reactive (when using your .env)
source .env && cast block-number --rpc-url "$REACTIVE_RPC"
```

## Next Steps

Once RPC endpoints are working:

1. ✅ Run `./validate-env.sh` to verify everything
2. ✅ Ensure you have test ETH (use faucets from ENV_SETUP.md)
3. ✅ Run `./deploy.sh` to deploy contracts

## Troubleshooting

### "connection refused" or timeout errors

**Cause**: RPC endpoint is down, rate-limited, or blocked

**Fix**:
1. Use Alchemy or Infura (recommended)
2. Check your internet connection
3. Try a VPN if geographic restrictions apply

### "invalid API key"

**Cause**: API key not copied correctly

**Fix**:
1. Verify the full URL in .env
2. No extra spaces or quotes
3. Regenerate API key if needed

---

**Recommended**: Use Alchemy for the most reliable experience. It's free for testnet usage! 🚀
