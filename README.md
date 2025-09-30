# A10D - Decentralized Event Ticketing System

A revolutionary event ticketing DApp built on the **Reactive Network** that prevents fraud and scalping through autonomous cross-chain validation using Reactive Smart Contracts.

![Reactive Network](https://img.shields.io/badge/Reactive-Network-blue)
![Solidity](https://img.shields.io/badge/Solidity-0.8.26-green)
![Foundry](https://img.shields.io/badge/Built%20with-Foundry-red)

## 🎯 Overview

A10D leverages the Reactive Network's cross-chain reactive capabilities to create a transparent, fair, and fraud-resistant event ticketing system. Unlike traditional ticketing platforms, A10D uses **Reactive Smart Contracts** that autonomously monitor and validate ticket transfers across blockchains in real-time.

### Key Features

- ✅ **NFT-Based Tickets** - Each ticket is a unique ERC-721 token
- 🛡️ **Anti-Scalping Protection** - Automated price validation and transfer limits
- 🔍 **Cross-Chain Monitoring** - Reactive contracts monitor ticket activity 24/7
- ⚡ **Autonomous Validation** - Automatic fraud detection without manual intervention
- 🌐 **Multi-Chain Support** - Works across different blockchain networks
- 📊 **Transparent History** - All ticket transfers are tracked and validated
- 🚫 **Blacklist System** - Automatic blacklisting of malicious actors

## 🏗️ Architecture

The system consists of three main smart contracts deployed across different chains:

```
┌─────────────────────────────────────────────────────────────────┐
│                     A10D ARCHITECTURE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Origin Chain (e.g., Sepolia)                                   │
│  ┌────────────────────────────┐                                │
│  │   EventTicket.sol          │  ← NFT Tickets                 │
│  │   - Mint tickets           │                                │
│  │   - Transfer tracking      │                                │
│  │   - Price validation       │                                │
│  └────────────────────────────┘                                │
│              │                                                   │
│              │ Emits Events                                     │
│              ▼                                                   │
│                                                                  │
│  Reactive Network (Kopli)                                       │
│  ┌────────────────────────────┐                                │
│  │ TicketReactiveValidator    │  ← Monitors & Validates        │
│  │   - Event monitoring       │                                │
│  │   - Transfer validation    │                                │
│  │   - Fraud detection        │                                │
│  └────────────────────────────┘                                │
│              │                                                   │
│              │ Sends Callbacks                                  │
│              ▼                                                   │
│                                                                  │
│  Destination Chain (e.g., Sepolia)                             │
│  ┌────────────────────────────┐                                │
│  │   TicketCallback.sol       │  ← Receives Validations        │
│  │   - Records history        │                                │
│  │   - Flags violations       │                                │
│  │   - Manages blacklist      │                                │
│  └────────────────────────────┘                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Smart Contracts

1. **EventTicket.sol** (Origin Chain)
   - ERC-721 NFT contract for event tickets
   - Implements transfer limits and price validation
   - Emits events for ticket minting and transfers

2. **TicketReactiveValidator.sol** (Reactive Network)
   - Monitors ticket events in real-time
   - Validates transfers against anti-scalping rules
   - Detects fraud patterns autonomously
   - Sends validation results to callback contract

3. **TicketCallback.sol** (Destination Chain)
   - Receives validation callbacks from Reactive Network
   - Maintains transfer history and violation records
   - Manages blacklist of malicious addresses
   - Flags suspicious tickets

## 🚀 Quick Start

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/)
- Test ETH on Sepolia (or your chosen testnet)
- Test ETH on Reactive Kopli testnet

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/A10d.git
cd A10d

# Install dependencies
forge install

# Copy environment file
cp .env.example .env
```

### Configuration

Edit `.env` with your configuration:

```bash
# Network RPC URLs
ORIGIN_RPC=https://rpc.sepolia.org
DESTINATION_RPC=https://rpc.sepolia.org
REACTIVE_RPC=https://kopli-rpc.rkt.ink

# Private Keys
ORIGIN_PRIVATE_KEY=your_private_key
DESTINATION_PRIVATE_KEY=your_private_key
REACTIVE_PRIVATE_KEY=your_private_key

# Chain IDs
ORIGIN_CHAIN_ID=11155111
DESTINATION_CHAIN_ID=11155111

# System Contracts (from Reactive Network docs)
SYSTEM_CONTRACT_ADDR=0x0000000000000000000000000000000000FFFFFF
DESTINATION_CALLBACK_PROXY_ADDR=0x0000000000000000000000000000000000FFFFFF
```

### Compile Contracts

```bash
forge build
```

### Run Tests

```bash
# Run all tests
forge test

# Run with verbose output
forge test -vv

# Run with detailed traces
forge test -vvvv
```

### Deploy

#### Option 1: Automated Deployment (Recommended)

```bash
# Make deployment script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

#### Option 2: Manual Deployment

```bash
# Step 1: Deploy TicketCallback to destination chain
forge create \
  --rpc-url $DESTINATION_RPC \
  --private-key $DESTINATION_PRIVATE_KEY \
  --value 0.02ether \
  --constructor-args $DESTINATION_CALLBACK_PROXY_ADDR \
  src/TicketCallback.sol:TicketCallback

# Step 2: Deploy EventTicket to origin chain
forge create \
  --rpc-url $ORIGIN_RPC \
  --private-key $ORIGIN_PRIVATE_KEY \
  src/EventTicket.sol:EventTicket

# Step 3: Deploy TicketReactiveValidator to Reactive Network
forge create \
  --rpc-url $REACTIVE_RPC \
  --private-key $REACTIVE_PRIVATE_KEY \
  --value 0.1ether \
  --constructor-args $SYSTEM_CONTRACT_ADDR $ORIGIN_CHAIN_ID $DESTINATION_CHAIN_ID <EVENT_TICKET_ADDR> <TICKET_CALLBACK_ADDR> \
  src/TicketReactiveValidator.sol:TicketReactiveValidator
```

## 📖 Usage Guide

### Creating an Event

```solidity
// Connect to EventTicket contract
uint256 eventId = eventTicket.createEvent(
    "Web3 Conference 2025",    // Event name
    100,                       // Max tickets
    0.1 ether,                // Price per ticket
    block.timestamp + 30 days, // Event date
    3                          // Max transfers per ticket
);
```

### Buying a Ticket

```solidity
// Mint a ticket
uint256 tokenId = eventTicket.mintTicket{value: 0.1 ether}(
    eventId,
    "ipfs://QmTicketMetadata..."
);
```

### Transferring a Ticket

```solidity
// Standard ERC-721 transfer
eventTicket.transferFrom(seller, buyer, tokenId);
// Reactive contract automatically monitors and validates this transfer!
```

### Validating at Event

```solidity
// At event entrance
eventTicket.validateTicket(tokenId);
```

## 🔐 Anti-Scalping Mechanisms

### 1. Transfer Limits
- Each ticket has a maximum number of transfers (set by event organizer)
- Prevents excessive flipping and bot activity

### 2. Price Validation
- Maximum resale price capped at 110% of original price
- Violations are automatically detected and reported

### 3. Automatic Blacklisting
- Addresses involved in 3+ violations are automatically blacklisted
- Blacklisted addresses are tracked on the callback contract

### 4. Real-Time Monitoring
- Reactive contracts monitor all transfers 24/7
- No manual intervention required

## 🧪 Testing

The project includes comprehensive tests:

```bash
# Run all tests
forge test

# Run specific test file
forge test --match-path test/EventTicket.t.sol

# Run specific test
forge test --match-test testMintTicket

# Generate coverage report
forge coverage
```

### Test Coverage

- ✅ Event creation
- ✅ Ticket minting
- ✅ Ticket transfers
- ✅ Transfer limit enforcement
- ✅ Price validation
- ✅ Ticket validation at event
- ✅ Double validation prevention
- ✅ Sold out scenarios

## 🌐 Network Information

### Reactive Network Kopli Testnet

- **RPC URL**: `https://kopli-rpc.rkt.ink`
- **Chain ID**: `5318008`
- **Explorer**: https://kopli.reactscan.net/
- **Faucet**: https://dev.reactive.network/docs/kopli-testnet

### Supported Origin/Destination Chains

- Ethereum Sepolia
- Polygon Mumbai
- Arbitrum Goerli
- Any EVM-compatible chain

## 🛠️ Project Structure

```
A10d/
├── src/
│   ├── EventTicket.sol              # Main NFT ticket contract
│   ├── TicketCallback.sol           # Validation callback receiver
│   ├── TicketReactiveValidator.sol  # Reactive monitoring contract
│   └── interfaces/
│       ├── IReactive.sol            # Reactive Network interface
│       └── ISubscriptionService.sol # Subscription service interface
├── script/
│   └── Deploy.s.sol                 # Deployment scripts
├── test/
│   └── EventTicket.t.sol           # Test suite
├── foundry.toml                     # Foundry configuration
├── deploy.sh                        # Automated deployment script
├── .env.example                     # Environment template
└── README.md                        # This file
```

## 🔧 Advanced Configuration

### Customizing Anti-Scalping Rules

Edit `EventTicket.sol`:

```solidity
// Change maximum price increase (currently 110%)
uint256 public constant MAX_PRICE_INCREASE = 110;

// Modify in createEvent() call
function createEvent(..., uint256 _maxTransfersPerTicket) {
    // Adjust max transfers per event
}
```

### Adding Custom Validations

Edit `TicketReactiveValidator.sol`:

```solidity
function _handleTicketTransfer(...) private {
    // Add custom validation logic
    if (/* your condition */) {
        isValid = false;
        reason = "Your custom reason";
    }
}
```

## 📚 Learn More

- [Reactive Network Documentation](https://dev.reactive.network/)
- [Reactive Smart Contract Demos](https://github.com/Reactive-Network/reactive-smart-contract-demos)
- [Foundry Book](https://book.getfoundry.sh/)
- [ERC-721 Standard](https://eips.ethereum.org/EIPS/eip-721)

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Reactive Network** for providing the reactive smart contract infrastructure
- **OpenZeppelin** for secure smart contract libraries
- **Foundry** for the excellent development framework

## 📞 Support

For questions and support:
- Open an issue on GitHub
- Join our Discord community
- Follow us on Twitter [@A10D_Tickets]

## 🚧 Roadmap

- [ ] Multi-event ticket bundles
- [ ] Secondary marketplace integration
- [ ] Mobile app for ticket validation
- [ ] Integration with major event platforms
- [ ] DAO governance for platform fees
- [ ] NFT ticket art generator
- [ ] Loyalty rewards for honest buyers

---

**Built with ❤️ on the Reactive Network**

*Making event ticketing fair, transparent, and fraud-free.*
