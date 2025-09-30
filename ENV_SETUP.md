# Environment Setup Guide

## Quick Start

Your `.env` file needs to be configured before deployment. Here's how:

### Step 1: Copy the example

```bash
cp .env.example .env
```

### Step 2: Edit your `.env` file

```bash
nano .env
```

### Step 3: Configure Required Values

#### **Option A: Use the Same Account for All Chains (Simplest)**

If you want to use the same private key for all three chains:

```bash
# Get your private key from MetaMask:
# 1. Open MetaMask
# 2. Click the three dots → Account Details → Export Private Key
# 3. Enter your password and copy the key

# Replace in .env:
ORIGIN_PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
DESTINATION_PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
REACTIVE_PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
```

#### **Option B: Use Different Accounts (More Secure)**

Use separate accounts for each chain if you prefer isolation.

### Step 4: Verify System Contract Addresses

The `.env.example` already has the correct addresses:

```bash
SYSTEM_CONTRACT_ADDR=0x0000000000000000000000000000000000fffFfF
DESTINATION_CALLBACK_PROXY_ADDR=0x0000000000000000000000000000000000fffFfF
```

**DO NOT change these!** They are the official Reactive Network system contracts.

### Step 5: Get Test Tokens

You need test ETH on each chain:

#### **Sepolia (Origin & Destination):**
- https://sepoliafaucet.com/
- https://www.alchemy.com/faucets/ethereum-sepolia
- https://faucet.quicknode.com/ethereum/sepolia

#### **Reactive Kopli Testnet:**
- https://dev.reactive.network/docs/kopli-testnet
- Join their Discord for testnet tokens

### Step 6: (Optional) Etherscan API Key

For contract verification:

1. Go to https://etherscan.io/myapikey
2. Create an API key
3. Add to `.env`:
   ```bash
   ETHERSCAN_API_KEY=YOUR_API_KEY_HERE
   ```

## Example .env File

Here's what a complete `.env` should look like:

```bash
# Network RPC URLs
ORIGIN_RPC=https://rpc.sepolia.org
DESTINATION_RPC=https://rpc.sepolia.org
REACTIVE_RPC=https://kopli-rpc.rkt.ink

# Private Keys
ORIGIN_PRIVATE_KEY=0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
DESTINATION_PRIVATE_KEY=0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
REACTIVE_PRIVATE_KEY=0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890

# Chain IDs
ORIGIN_CHAIN_ID=11155111
DESTINATION_CHAIN_ID=11155111
REACTIVE_CHAIN_ID=5318008

# System Contracts (Reactive Network)
SYSTEM_CONTRACT_ADDR=0x0000000000000000000000000000000000fffFfF
DESTINATION_CALLBACK_PROXY_ADDR=0x0000000000000000000000000000000000fffFfF

# Deployed Contract Addresses (auto-filled after deployment)
EVENT_TICKET_ADDR=
TICKET_CALLBACK_ADDR=
TICKET_REACTIVE_ADDR=

# Etherscan API Key
ETHERSCAN_API_KEY=ABC123DEF456
```

## Verify Your Setup

Before deploying, check that you have:

✅ Private keys configured
✅ Test ETH on all chains
✅ RPC URLs accessible

Test your RPC connection:

```bash
# Test Sepolia
cast block-number --rpc-url https://rpc.sepolia.org

# Test Reactive Kopli
cast block-number --rpc-url https://kopli-rpc.rkt.ink
```

## Security Warnings

⚠️ **NEVER commit your `.env` file to Git!**
⚠️ **Use TESTNET private keys only!**
⚠️ **Keep your private keys secure!**

## Deploy!

Once configured:

```bash
./deploy.sh
```

## Troubleshooting

### "error: the following required arguments were not provided: <CONTRACT>"

**Cause:** `.env` file is not configured or variables are empty.

**Fix:**
1. Ensure `.env` exists: `ls -la .env`
2. Check it has values: `cat .env | grep PRIVATE_KEY`
3. Make sure no `your_private_key_here` placeholders remain

### "insufficient funds for gas * price + value"

**Cause:** Not enough test ETH in your account.

**Fix:** Get more test tokens from the faucets listed above.

### "connection refused" or "network error"

**Cause:** RPC endpoint is down or unreachable.

**Fix:**
1. Try alternative RPC URLs
2. Check your internet connection
3. Verify the chain is operational

---

**Need help?** Check the Reactive Network documentation: https://dev.reactive.network/docs
