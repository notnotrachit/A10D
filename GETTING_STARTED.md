# Getting Started with A10D

Welcome to A10D! This guide will get you up and running in minutes.

## 🎯 What is A10D?

A10D is a decentralized event ticketing system that uses **Reactive Smart Contracts** to automatically prevent fraud and scalping. Think of it as a self-enforcing ticketing platform that runs 24/7 without human intervention.

## ⚡ 5-Minute Quick Start

### Step 1: Install Foundry
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Step 2: Get the Code
```bash
cd /Users/rachit/Documents/GitHub-Personal/A10d
```

### Step 3: Install Dependencies
```bash
./setup.sh
```

### Step 4: Configure Environment
```bash
# The setup script created .env for you
# Edit it with your settings:
nano .env
```

Required settings:
- `ORIGIN_PRIVATE_KEY` - Your wallet private key
- `DESTINATION_PRIVATE_KEY` - Can be same as origin
- `REACTIVE_PRIVATE_KEY` - Can be same as origin

### Step 5: Get Test ETH
- **Sepolia**: https://sepoliafaucet.com/
- **Reactive Kopli**: https://dev.reactive.network/docs/kopli-testnet

### Step 6: Deploy
```bash
./deploy.sh
```

### Step 7: Test It Out
```bash
# Create an event
./scripts/interact.sh create-event

# Mint a ticket
./scripts/interact.sh mint 1

# Check ticket info
./scripts/interact.sh ticket-info 1
```

## 🎓 Next Steps

### For Event Organizers
1. Read [Creating Your First Event](#creating-an-event)
2. Understand [Anti-Scalping Settings](#anti-scalping-settings)
3. Learn about [Event Management](#event-management)

### For Developers
1. Read [ARCHITECTURE.md](./ARCHITECTURE.md)
2. Explore the smart contracts in `src/`
3. Run tests: `forge test -vv`

### For Integrators
1. Read [Integration Guide](./ARCHITECTURE.md#integration-guide)
2. Check out example scripts in `scripts/`
3. Review the [API Reference](#api-reference)

## 📖 Core Concepts

### 1. Reactive Smart Contracts

Traditional smart contracts are **passive** - they only execute when someone calls them.

**Reactive Smart Contracts are active** - they monitor the blockchain and execute automatically when conditions are met.

```
Traditional:          Reactive:
User → Contract      Event → Contract → Action
```

### 2. Three-Contract Architecture

**EventTicket** (Origin Chain):
- Where tickets are minted and transferred
- Enforces transfer limits
- Validates prices

**TicketReactiveValidator** (Reactive Network):
- Monitors all ticket activity
- Validates transfers automatically
- Detects fraud patterns

**TicketCallback** (Destination Chain):
- Receives validation results
- Maintains violation history
- Manages blacklist

### 3. Anti-Scalping Mechanisms

**Transfer Limits**:
- Each ticket has max number of transfers
- Prevents excessive flipping
- Set by event organizer

**Price Caps**:
- Maximum resale price: 110% of original
- Automatically enforced
- Violations trigger alerts

**Automatic Blacklisting**:
- 3 violations = permanent ban
- Tracked on-chain
- Cannot be bypassed

## 🎫 Creating an Event

### Using Cast (CLI)

```bash
cast send $EVENT_TICKET_ADDR \
  "createEvent(string,uint256,uint256,uint256,uint256)" \
  "Web3 Conference 2025" \
  100 \
  100000000000000000 \
  $(($(date +%s) + 2592000)) \
  3 \
  --rpc-url $ORIGIN_RPC \
  --private-key $ORIGIN_PRIVATE_KEY
```

### Parameters Explained

1. **Event Name**: "Web3 Conference 2025"
2. **Max Tickets**: 100 (total supply)
3. **Price**: 100000000000000000 (0.1 ETH in wei)
4. **Event Date**: Unix timestamp (30 days from now)
5. **Max Transfers**: 3 (ticket can be transferred 3 times)

### Using Helper Script

```bash
./scripts/interact.sh create-event
```

## 🎟️ Buying Tickets

### As a Buyer

```bash
# Mint a ticket for event #1
./scripts/interact.sh mint 1
```

### What Happens

1. ✅ Payment sent to event organizer
2. ✅ NFT minted to your address
3. ✅ TicketMinted event emitted
4. ✅ Reactive contract starts monitoring
5. ✅ You own the ticket!

## 🔄 Transferring Tickets

### Standard Transfer

```bash
./scripts/interact.sh transfer <TOKEN_ID> <TO_ADDRESS>
```

### What Happens Automatically

1. ✅ Transfer executes on EventTicket contract
2. ✅ Transfer count incremented
3. ✅ TicketTransferred event emitted
4. ⚡ **Reactive contract detects event**
5. ⚡ **Validates transfer (< 1 second)**
6. ⚡ **Sends result to callback contract**
7. ✅ Validation result recorded

## 🔍 Checking Status

### Check if Ticket is Flagged

```bash
./scripts/interact.sh check-flagged <TOKEN_ID>
```

### Check Transfer History

```bash
./scripts/interact.sh transfer-history <TOKEN_ID>
```

### Check Blacklist

```bash
./scripts/interact.sh check-blacklisted <ADDRESS>
```

## 🎭 At the Event

### Validate Ticket at Entrance

```bash
# Ticket holder validates their ticket
./scripts/interact.sh validate <TOKEN_ID>
```

### What Happens

1. ✅ Verifies ownership
2. ✅ Marks ticket as used
3. ✅ Prevents double-validation
4. ✅ Emits validation event

## 🧪 Testing

### Run All Tests

```bash
forge test -vv
```

### Run Specific Test

```bash
forge test --match-test testMintTicket -vvvv
```

### Generate Coverage

```bash
forge coverage
```

## 🔧 Configuration

### Environment Variables

```bash
# Network RPCs
ORIGIN_RPC=https://rpc.sepolia.org
DESTINATION_RPC=https://rpc.sepolia.org
REACTIVE_RPC=https://kopli-rpc.rkt.ink

# Chain IDs
ORIGIN_CHAIN_ID=11155111        # Sepolia
DESTINATION_CHAIN_ID=11155111   # Sepolia
REACTIVE_CHAIN_ID=5318008       # Reactive Kopli

# System Contracts (from Reactive docs)
SYSTEM_CONTRACT_ADDR=0x0000000000000000000000000000000000FFFFFF
DESTINATION_CALLBACK_PROXY_ADDR=0x0000000000000000000000000000000000FFFFFF
```

### Customizing Anti-Scalping

Edit `src/EventTicket.sol`:

```solidity
// Change maximum price increase
uint256 public constant MAX_PRICE_INCREASE = 110; // 110% = 10% markup

// When creating event, adjust max transfers
ticket.createEvent(..., 5); // Allow 5 transfers instead of 3
```

## 📊 Monitoring

### View Contract Addresses

```bash
echo "EventTicket: $EVENT_TICKET_ADDR"
echo "TicketCallback: $TICKET_CALLBACK_ADDR"
echo "TicketReactive: $TICKET_REACTIVE_ADDR"
```

### Check Balances

```bash
cast balance $EVENT_TICKET_ADDR --rpc-url $ORIGIN_RPC
cast balance $TICKET_REACTIVE_ADDR --rpc-url $REACTIVE_RPC
```

### View Recent Events

```bash
cast logs --address $EVENT_TICKET_ADDR \
  --from-block -100 \
  --to-block latest \
  --rpc-url $ORIGIN_RPC
```

## ⚠️ Common Issues

### "Insufficient funds for gas"
**Solution**: Get more test ETH from faucets

### "Event is not active"
**Solution**: Event may have been deactivated by organizer

### "Ticket has exceeded maximum transfer limit"
**Solution**: Ticket cannot be transferred anymore

### "Insufficient payment"
**Solution**: Check ticket price with `./scripts/interact.sh event-info <EVENT_ID>`

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for more help.

## 📚 Documentation

- **[README.md](./README.md)** - Complete project documentation
- **[QUICKSTART.md](./QUICKSTART.md)** - Quick setup guide
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Technical deep dive
- **[SECURITY.md](./SECURITY.md)** - Security analysis
- **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Debug guide
- **[PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md)** - Project summary

## 🤝 Getting Help

1. **Check Documentation** - Most questions answered in docs
2. **Search Issues** - Someone may have had same problem
3. **Ask in Discord** - Community support
4. **Open an Issue** - For bugs and feature requests

## 🚀 What's Next?

Once you're comfortable with the basics:

1. **Deploy to Production**
   - Get mainnet ETH
   - Update RPC URLs
   - Deploy contracts
   - Verify on Etherscan

2. **Integrate with Frontend**
   - Use web3.js or ethers.js
   - Connect to MetaMask
   - Build ticket marketplace

3. **Customize for Your Use Case**
   - Modify anti-scalping rules
   - Add custom validation logic
   - Implement royalties

4. **Scale Up**
   - Deploy on L2s
   - Add more chains
   - Build ecosystem

## 💡 Pro Tips

1. **Start Small**: Test with small events first
2. **Monitor Closely**: Watch validation success rates
3. **Engage Community**: Get feedback from users
4. **Iterate Fast**: Web3 moves quickly
5. **Stay Secure**: Regular audits and updates

## 🎉 Success!

You're now ready to revolutionize event ticketing with A10D!

**Happy building! 🎫**

---

Questions? Open an issue or reach out to the community!
