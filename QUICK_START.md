# 🚀 Quick Start - Ready to Deploy!

## Great News! You Found Working RPC Endpoints!

The RPC endpoints you provided are working. Here's what to do next:

## Step 1: Update Your `.env` File

Open your `.env` file and make sure it has these values:

```bash
# Network RPC URLs
ORIGIN_RPC=https://eth-sepolia.public.blastapi.io
DESTINATION_RPC=https://eth-sepolia.public.blastapi.io
REACTIVE_RPC=https://lasna-rpc.rnk.dev/

# Chain IDs
ORIGIN_CHAIN_ID=11155111
DESTINATION_CHAIN_ID=11155111
REACTIVE_CHAIN_ID=5318007

# System Contracts
SYSTEM_CONTRACT_ADDR=0x0000000000000000000000000000000000fffFfF
DESTINATION_CALLBACK_PROXY_ADDR=0x0000000000000000000000000000000000fffFfF

# Private Keys (with 0x prefix - you should have these already)
ORIGIN_PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
DESTINATION_PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
REACTIVE_PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
```

**Important Changes:**
- ✅ RPC URLs updated to working endpoints
- ✅ Chain ID changed from **5318008** (Kopli) to **5318007** (Lasna)
- ✅ Using Reactive Lasna testnet instead of Kopli

## Step 2: Get Test Tokens

You need test tokens on **3 chains**:

### Ethereum Sepolia
Get test ETH from these faucets:
- https://sepoliafaucet.com/
- https://www.alchemy.com/faucets/ethereum-sepolia
- https://faucet.quicknode.com/ethereum/sepolia

### Reactive Lasna
Get REACT tokens:
- Check: https://dev.reactive.network/docs
- Join Discord: https://discord.gg/reactive-network
- Ask in their faucet channel

**Note**: You need the same address to have tokens on all 3 networks.

## Step 3: Verify Balance

Check you have test tokens:

```bash
# Get your address
cast wallet address 0xYOUR_PRIVATE_KEY

# Check Sepolia balance
cast balance YOUR_ADDRESS --rpc-url https://eth-sepolia.public.blastapi.io

# Check Reactive balance
cast balance YOUR_ADDRESS --rpc-url https://lasna-rpc.rnk.dev/
```

You should have at least:
- **0.2 ETH on Sepolia** (for deploying 2 contracts)
- **0.15 REACT on Lasna** (for deploying reactive validator)

## Step 4: Deploy!

```bash
# Run deployment script
./deploy.sh
```

Expected output:
```
========================================
   A10D Event Ticketing Deployment
========================================

Step 1: Deploying TicketCallback to destination chain...
  RPC: https://eth-sepolia.public.blastapi.io
  Constructor arg: 0x0000000000000000000000000000000000fffFfF

✓ TicketCallback deployed at: 0x...

Step 2: Deploying EventTicket to origin chain...
  RPC: https://eth-sepolia.public.blastapi.io

✓ EventTicket deployed at: 0x...

Step 3: Deploying TicketReactiveValidator to Reactive Network...
  RPC: https://lasna-rpc.rnk.dev/
  ...

✓ TicketReactiveValidator deployed at: 0x...

========================================
         Deployment Summary
========================================

Origin Chain (Chain ID: 11155111)
  EventTicket: 0x...

Destination Chain (Chain ID: 11155111)
  TicketCallback: 0x...

Reactive Network
  TicketReactiveValidator: 0x...

Deployment complete! 🎉
```

## Troubleshooting

### "insufficient funds for gas"
**Solution**: Get more test tokens from faucets

### "nonce too low" or "replacement transaction underpriced"
**Solution**: Wait a few seconds and try again

### "execution reverted"
**Solution**: Check constructor arguments are correct in deploy.sh

## After Deployment

Once deployed, you can:

1. **View contracts on block explorers:**
   - Sepolia: https://sepolia.etherscan.io/
   - Reactive: https://lasna.reactscan.net/

2. **Test the system:**
   ```bash
   # Create an event
   ./scripts/interact.sh create-event
   
   # Mint a ticket
   ./scripts/interact.sh mint 1
   ```

3. **Update `.env` with deployed addresses** (script will output these)

---

**You're almost there! Just need test tokens and you can deploy! 🎫🚀**
