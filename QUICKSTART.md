# A10D Quick Start Guide

Get your A10D Event Ticketing DApp running in minutes!

## ⚡ Fast Setup

### 1. Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Clone & Install

```bash
git clone <your-repo-url>
cd A10d
forge install
```

### 3. Configure Environment

```bash
cp .env.example .env
# Edit .env with your settings
```

### 4. Install Dependencies

```bash
# Install OpenZeppelin contracts
forge install OpenZeppelin/openzeppelin-contracts --no-commit

# Install Forge Standard Library
forge install foundry-rs/forge-std --no-commit
```

### 5. Compile

```bash
forge build
```

### 6. Test

```bash
forge test -vv
```

### 7. Deploy

```bash
chmod +x deploy.sh
./deploy.sh
```

## 🎫 Create Your First Event

After deployment, interact with the contracts:

```bash
# Using cast (Foundry's CLI tool)
cast send $EVENT_TICKET_ADDR \
  "createEvent(string,uint256,uint256,uint256,uint256)" \
  "My First Event" \
  100 \
  100000000000000000 \
  $(($(date +%s) + 2592000)) \
  3 \
  --rpc-url $ORIGIN_RPC \
  --private-key $ORIGIN_PRIVATE_KEY
```

## 📋 Essential Commands

### Compile contracts
```bash
forge build
```

### Run tests
```bash
forge test
forge test -vv          # Verbose
forge test -vvvv        # Very verbose with traces
```

### Deploy individual contracts
```bash
# Deploy EventTicket
forge create --rpc-url $ORIGIN_RPC \
  --private-key $ORIGIN_PRIVATE_KEY \
  src/EventTicket.sol:EventTicket

# Deploy TicketCallback
forge create --rpc-url $DESTINATION_RPC \
  --private-key $DESTINATION_PRIVATE_KEY \
  --value 0.02ether \
  --constructor-args $DESTINATION_CALLBACK_PROXY_ADDR \
  src/TicketCallback.sol:TicketCallback

# Deploy TicketReactiveValidator
forge create --rpc-url $REACTIVE_RPC \
  --private-key $REACTIVE_PRIVATE_KEY \
  --value 0.1ether \
  --constructor-args $SYSTEM_CONTRACT_ADDR $ORIGIN_CHAIN_ID $DESTINATION_CHAIN_ID $EVENT_TICKET_ADDR $TICKET_CALLBACK_ADDR \
  src/TicketReactiveValidator.sol:TicketReactiveValidator
```

### Check contract state
```bash
# Get event info
cast call $EVENT_TICKET_ADDR \
  "getEventInfo(uint256)" 1 \
  --rpc-url $ORIGIN_RPC

# Get ticket info
cast call $EVENT_TICKET_ADDR \
  "getTicketInfo(uint256)" 1 \
  --rpc-url $ORIGIN_RPC

# Check if ticket is flagged
cast call $TICKET_CALLBACK_ADDR \
  "isTicketFlagged(uint256)" 1 \
  --rpc-url $DESTINATION_RPC
```

## 🔑 Getting Test ETH

### For Sepolia (Origin/Destination)
- https://sepoliafaucet.com/
- https://faucet.quicknode.com/ethereum/sepolia

### For Reactive Kopli
- https://dev.reactive.network/docs/kopli-testnet
- Request tokens in Reactive Discord

## ⚠️ Common Issues

### "Insufficient funds for gas"
Make sure your wallets have test ETH on all chains:
- Origin chain (Sepolia): ~0.5 ETH
- Destination chain (Sepolia): ~0.5 ETH  
- Reactive Network (Kopli): ~1 ETH

### "Invalid callback sender"
Ensure you're using the correct callback proxy address from Reactive Network docs.

### "Compilation failed"
Run `forge install` again and make sure remappings.txt exists.

## 🎯 Next Steps

1. **Create an event** - Use the EventTicket contract
2. **Mint tickets** - Test the buying flow
3. **Transfer tickets** - Watch the reactive validation in action
4. **Check validations** - View results on the TicketCallback contract

## 📚 Learn More

- Full README: [README.md](./README.md)
- Reactive Network: https://dev.reactive.network/
- Foundry Book: https://book.getfoundry.sh/

---

Need help? Open an issue on GitHub!
