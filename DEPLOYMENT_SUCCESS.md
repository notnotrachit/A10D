# 🎉 A10D Event Ticketing - Deployment Complete!

## ✅ All Contracts Successfully Deployed

### **1. EventTicket (Origin Chain - Sepolia)**
- **Address**: `0x7CF4DA7307AC0213542b6838969058469c412555`
- **Chain ID**: 11155111 (Sepolia)
- **View on Etherscan**: https://sepolia.etherscan.io/address/0x7CF4DA7307AC0213542b6838969058469c412555
- **Purpose**: Main ticketing NFT contract where events are created and tickets are minted

### **2. TicketCallback (Destination Chain - Sepolia)**
- **Address**: `0xE3B386573Af8f8050C7EF24260d2cCcdCE21044d`
- **Chain ID**: 11155111 (Sepolia)
- **View on Etherscan**: https://sepolia.etherscan.io/address/0xE3B386573Af8f8050C7EF24260d2cCcdCE21044d
- **Purpose**: Receives validation callbacks from Reactive Network about ticket transfers

### **3. TicketReactiveValidator (Reactive Network - Lasna)**
- **Address**: `0x0ab8d701f6f45Fe21fA6b63199703ACA121D3Dc8`
- **Chain ID**: 5318007 (Lasna Testnet)
- **View on Reactscan**: https://lasna.reactscan.net/address/0x0ab8d701f6f45Fe21fA6b63199703ACA121D3Dc8
- **Purpose**: Monitors ticket events on Sepolia and validates transfers to prevent scalping
- **Status**: ✅ Subscribed to events (Transaction: 0x8f2419a07946600a749415218d650271be504f4b118394f8d0a6b9de076a6350)

## Deployment Details

### Gas Costs

| Contract | Chain | Gas Used | Cost (ETH/REACT) |
|----------|-------|----------|------------------|
| EventTicket | Sepolia | ~2.1M gas | ~0.036 ETH |
| TicketCallback | Sepolia | ~2.1M gas | ~0.036 ETH |
| TicketReactiveValidator | Lasna | 1,356,718 gas | 0.136 REACT |
| Subscription Setup | Lasna | 288,566 gas | 0.029 REACT |
| **Total** | | | **~0.072 ETH + 0.165 REACT** |

### Event Subscriptions

The reactive validator is now monitoring:
- ✅ **TicketTransferred** - Tracks all ticket transfers and validates against limits
- ✅ **TicketMinted** - Initializes tracking for newly minted tickets
- ✅ **PriceViolation** - Flags tickets with suspicious pricing

## How to Use

### 1. Create an Event

```bash
cast send 0x7CF4DA7307AC0213542b6838969058469c412555 \
  "createEvent(string,uint256,uint256,uint256,uint256)" \
  "Web3 Conference 2025" \
  100 \
  100000000000000000 \
  $(($(date +%s) + 86400)) \
  3 \
  --rpc-url https://eth-sepolia.public.blastapi.io \
  --private-key $ORIGIN_PRIVATE_KEY
```

Parameters:
- Event name: "Web3 Conference 2025"
- Max tickets: 100
- Price: 0.1 ETH (100000000000000000 wei)
- Event date: Tomorrow (current timestamp + 86400 seconds)
- Max transfers: 3

### 2. Mint a Ticket

```bash
cast send 0x7CF4DA7307AC0213542b6838969058469c412555 \
  "mintTicket(uint256,string)" \
  1 \
  "ipfs://QmYourTicketMetadata" \
  --value 0.1ether \
  --rpc-url https://eth-sepolia.public.blastapi.io \
  --private-key $ORIGIN_PRIVATE_KEY
```

### 3. Transfer a Ticket

```bash
cast send 0x7CF4DA7307AC0213542b6838969058469c412555 \
  "transferFrom(address,address,uint256)" \
  $YOUR_ADDRESS \
  $RECIPIENT_ADDRESS \
  1 \
  --rpc-url https://eth-sepolia.public.blastapi.io \
  --private-key $ORIGIN_PRIVATE_KEY
```

### 4. Validate Ticket (At Event)

```bash
cast send 0x7CF4DA7307AC0213542b6838969058469c412555 \
  "validateTicket(uint256)" \
  1 \
  --rpc-url https://eth-sepolia.public.blastapi.io \
  --private-key $ORIGIN_PRIVATE_KEY
```

### 5. Check Validation Results

View on the callback contract:

```bash
cast call 0xE3B386573Af8f8050C7EF24260d2cCcdCE21044d \
  "transferHistory(uint256,uint256)" \
  1 \
  0 \
  --rpc-url https://eth-sepolia.public.blastapi.io
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Ethereum Sepolia                         │
│                                                             │
│  ┌──────────────────┐         ┌─────────────────────┐      │
│  │  EventTicket     │         │  TicketCallback     │      │
│  │  (Origin)        │         │  (Destination)      │      │
│  │                  │         │                     │      │
│  │ • Create Events  │         │ • Receive Results   │      │
│  │ • Mint Tickets   │         │ • Flag Violations   │      │
│  │ • Transfer NFTs  │         │ • Track History     │      │
│  │ • Validate Entry │         │                     │      │
│  └──────┬───────────┘         └─────────▲───────────┘      │
│         │                               │                  │
└─────────┼───────────────────────────────┼──────────────────┘
          │                               │
          │ Events                        │ Callbacks
          ▼                               │
┌─────────────────────────────────────────────────────────────┐
│              Reactive Network (Lasna)                       │
│                                                             │
│         ┌──────────────────────────────────┐               │
│         │  TicketReactiveValidator         │               │
│         │                                  │               │
│         │ • Monitor Events                 │               │
│         │ • Validate Transfers             │               │
│         │ • Detect Scalping                │               │
│         │ • Send Callbacks                 │               │
│         └──────────────────────────────────┘               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Features

### Anti-Scalping Mechanisms
- ✅ **Transfer Limit Enforcement** - Max 3 transfers per ticket
- ✅ **Price Violation Detection** - Flags tickets sold >10% above face value
- ✅ **Real-time Monitoring** - Reactive validator watches all transfers
- ✅ **Blacklist Support** - Suspicious addresses can be flagged
- ✅ **Automated Validation** - Cross-chain verification without manual intervention

### Smart Contract Features
- ✅ **ERC-721 NFT Standard** - Full NFT compatibility
- ✅ **Event Management** - Create multiple events with different parameters
- ✅ **Attendance Tracking** - Mark tickets as used at event entrance
- ✅ **Royalty Support** - Optional royalties for organizers
- ✅ **Metadata Storage** - IPFS integration for ticket metadata

## Testing

Run the test suite:

```bash
forge test -vv
```

All 8 tests passing:
- ✅ testCreateEvent
- ✅ testMintTicket
- ✅ testTransferTicket
- ✅ testValidateTicket
- ✅ testPriceValidation
- ✅ test_RevertWhen_ExcessiveTransfers
- ✅ test_RevertWhen_DoubleValidation
- ✅ test_RevertWhen_MintAfterSoldOut

## Next Steps

1. **Verify Contracts** (Optional but recommended):
   ```bash
   forge verify-contract 0x7CF4DA7307AC0213542b6838969058469c412555 \
     src/EventTicket.sol:EventTicket \
     --chain sepolia \
     --etherscan-api-key $ETHERSCAN_API_KEY
   ```

2. **Test the System**:
   - Create a test event
   - Mint a few tickets
   - Transfer them between addresses
   - Check validation results on callback contract

3. **Monitor Events**:
   - Watch Reactscan: https://lasna.reactscan.net/address/0x0ab8d701f6f45Fe21fA6b63199703ACA121D3Dc8
   - Check Sepolia transactions: https://sepolia.etherscan.io/

4. **Build Frontend** (Optional):
   - Connect to contracts via Web3
   - Display events and tickets
   - Allow users to mint and transfer

## Troubleshooting

### If subscriptions fail:
Re-run the subscription setup:
```bash
cast send 0x0ab8d701f6f45Fe21fA6b63199703ACA121D3Dc8 \
  "subscribeToEvents()" \
  --rpc-url https://lasna-rpc.rnk.dev/ \
  --private-key $REACTIVE_PRIVATE_KEY
```

### To check validator state:
```bash
# Check if ticket is flagged
cast call 0x0ab8d701f6f45Fe21fA6b63199703ACA121D3Dc8 \
  "suspiciousTickets(uint256)" \
  1 \
  --rpc-url https://lasna-rpc.rnk.dev/
```

## Security Considerations

- ✅ All contracts use OpenZeppelin libraries
- ✅ Access control implemented (onlyOwner, onlyOrganizer)
- ✅ Reentrancy protection on payable functions
- ✅ Input validation on all external functions
- ⚠️  **Testnet only** - Do not use with real funds

## Resources

- **Reactive Network Docs**: https://dev.reactive.network/
- **Sepolia Faucet**: https://sepoliafaucet.com/
- **Project Repository**: /Users/rachit/Documents/GitHub-Personal/A10d

---

**Congratulations! Your decentralized event ticketing platform is live! 🎫🎉**

Built with ❤️ using:
- Solidity 0.8.26
- Foundry
- OpenZeppelin
- Reactive Network
