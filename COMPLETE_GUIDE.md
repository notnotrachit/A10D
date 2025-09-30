# 🎉 A10D Event Ticketing - Complete Project Guide

A fully functional decentralized event ticketing platform with anti-scalping protection, powered by Reactive Network.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Smart Contracts](#smart-contracts)
4. [Frontend Web App](#frontend-web-app)
5. [Quick Start](#quick-start)
6. [Testing](#testing)
7. [Deployment](#deployment)
8. [Usage Guide](#usage-guide)

---

## 🌟 Overview

A10D is a decentralized event ticketing platform that prevents scalping through:
- **Transfer Limits**: Tickets can only be transferred a maximum number of times
- **Price Caps**: Resale prices are capped at 10% above original price
- **Real-time Monitoring**: Reactive Network validates all transfers automatically
- **NFT Tickets**: Each ticket is a unique, ownable NFT

### Key Features

✅ **Anti-Scalping Protection**  
✅ **Transparent On-Chain Ticketing**  
✅ **Real-time Fraud Detection**  
✅ **Beautiful Web Interface**  
✅ **Cross-Chain Validation**  
✅ **No Hidden Fees**

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│              Frontend (Next.js + Wagmi)             │
│  - Browse Events  - Buy Tickets  - Create Events   │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│            Ethereum Sepolia Testnet                 │
│                                                     │
│  ┌──────────────────┐      ┌──────────────────┐   │
│  │  EventTicket     │      │  TicketCallback  │   │
│  │  (Origin)        │      │  (Destination)   │   │
│  │                  │      │                  │   │
│  │ • Mint Tickets   │      │ • Receive Result │   │
│  │ • Transfer NFTs  │      │ • Flag Issues    │   │
│  │ • Validate Entry │      │ • Track History  │   │
│  └────────┬─────────┘      └────────▲─────────┘   │
│           │                         │             │
└───────────┼─────────────────────────┼─────────────┘
            │                         │
            │ Events                  │ Callbacks
            ▼                         │
┌─────────────────────────────────────────────────────┐
│         Reactive Network (Lasna Testnet)            │
│                                                     │
│         ┌─────────────────────────────┐            │
│         │ TicketReactiveValidator     │            │
│         │                             │            │
│         │ • Monitor Transfers         │            │
│         │ • Validate Limits           │            │
│         │ • Detect Scalping           │            │
│         │ • Send Callbacks            │            │
│         └─────────────────────────────┘            │
└─────────────────────────────────────────────────────┘
```

---

## 📜 Smart Contracts

### 1. EventTicket (Sepolia)
**Address**: `0x7CF4DA7307AC0213542b6838969058469c412555`

Main ticketing contract that handles:
- Event creation
- Ticket minting (ERC-721 NFTs)
- Ticket transfers with limits
- Ticket validation at event entrance

### 2. TicketCallback (Sepolia)
**Address**: `0xE3B386573Af8f8050C7EF24260d2cCcdCE21044d`

Receives validation results from Reactive Network:
- Transfer validation results
- Suspicious activity flags
- Scalping detection alerts

### 3. TicketReactiveValidator (Reactive Lasna)
**Address**: `0x0ab8d701f6f45Fe21fA6b63199703ACA121D3Dc8`

Monitors and validates tickets:
- Subscribes to ticket events
- Validates transfer limits
- Detects price violations
- Sends callbacks to destination chain

---

## 🎨 Frontend Web App

Beautiful, modern web interface built with:
- Next.js 15 (App Router)
- Wagmi v2 & RainbowKit
- Tailwind CSS
- TypeScript

### Pages

1. **Home** (`/`) - Landing page with features
2. **Events** (`/events`) - Browse and buy tickets
3. **My Tickets** (`/my-tickets`) - Manage owned tickets
4. **Create Event** (`/create`) - Launch new events

### Current Status
✅ Frontend deployed locally at **http://localhost:3000**

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ or pnpm
- Foundry (for smart contracts)
- MetaMask wallet
- Sepolia testnet ETH

### 1. Clone & Install

```bash
cd /Users/rachit/Documents/GitHub-Personal/A10d

# Install smart contract dependencies
forge install

# Install frontend dependencies
cd frontend
pnpm install
```

### 2. Get Test Tokens

**Sepolia ETH**:
- https://sepoliafaucet.com/
- https://www.alchemy.com/faucets/ethereum-sepolia

**Reactive Lasna REACT**:
- https://dev.reactive.network/docs
- Discord: https://discord.gg/reactive-network

### 3. Start Frontend

```bash
cd frontend
pnpm dev
```

Open http://localhost:3000

### 4. Connect Wallet

1. Click "Connect Wallet" button
2. Select MetaMask (or your preferred wallet)
3. Switch to Sepolia testnet
4. Approve connection

---

## 🧪 Testing

### Run Smart Contract Tests

```bash
# Run all tests
forge test -vv

# Run specific test
forge test --match-test testMintTicket -vvv

# Run with gas report
forge test --gas-report
```

### Test Results
✅ All 8 tests passing:
- `testCreateEvent`
- `testMintTicket`
- `testTransferTicket`
- `testValidateTicket`
- `testPriceValidation`
- `test_RevertWhen_ExcessiveTransfers`
- `test_RevertWhen_DoubleValidation`
- `test_RevertWhen_MintAfterSoldOut`

---

## 🚢 Deployment

### Contracts Are Already Deployed! ✅

All contracts are live on testnets:

| Contract | Network | Address |
|----------|---------|---------|
| EventTicket | Sepolia | `0x7CF4DA7307AC0213542b6838969058469c412555` |
| TicketCallback | Sepolia | `0xE3B386573Af8f8050C7EF24260d2cCcdCE21044d` |
| TicketReactiveValidator | Reactive Lasna | `0x0ab8d701f6f45Fe21fA6b63199703ACA121D3Dc8` |

### Deployment Costs

- **Sepolia**: ~0.072 ETH total
  - EventTicket: ~0.036 ETH
  - TicketCallback: ~0.036 ETH

- **Reactive Lasna**: ~0.165 REACT total
  - Validator: 0.136 REACT
  - Subscriptions: 0.029 REACT

### To Redeploy (if needed)

```bash
# Deploy all contracts
./deploy-all.sh

# Or deploy individually
forge script script/DeployEventTicket.s.sol:DeployEventTicket \
  --rpc-url $ORIGIN_RPC \
  --private-key $ORIGIN_PRIVATE_KEY \
  --broadcast
```

---

## 📖 Usage Guide

### For Event Organizers

#### 1. Create an Event

**Via Frontend**:
1. Go to http://localhost:3000/create
2. Fill in event details:
   - Name: "Web3 Conference 2025"
   - Max Tickets: 100
   - Price: 0.1 ETH
   - Date: Select future date
   - Max Transfers: 3 (recommended)
3. Click "Create Event"
4. Approve transaction in wallet

**Via CLI**:
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

#### 2. Monitor Ticket Sales

Check event status:
```bash
cast call 0x7CF4DA7307AC0213542b6838969058469c412555 \
  "events(uint256)" 1 \
  --rpc-url https://eth-sepolia.public.blastapi.io
```

### For Ticket Buyers

#### 1. Browse Events

**Via Frontend**:
1. Go to http://localhost:3000/events
2. View all available events
3. See ticket availability and prices

#### 2. Buy Tickets

**Via Frontend**:
1. Click "Buy Ticket" on desired event
2. Approve transaction (pays ticket price)
3. Wait for confirmation
4. Ticket appears in "My Tickets"

**Via CLI**:
```bash
cast send 0x7CF4DA7307AC0213542b6838969058469c412555 \
  "mintTicket(uint256,string)" \
  1 \
  "ipfs://my-ticket-metadata" \
  --value 0.1ether \
  --rpc-url https://eth-sepolia.public.blastapi.io \
  --private-key $BUYER_PRIVATE_KEY
```

#### 3. Transfer Tickets

**Via Frontend**:
1. Go to http://localhost:3000/my-tickets
2. Select ticket to transfer
3. Enter recipient address
4. Click "Transfer"

**Via CLI**:
```bash
cast send 0x7CF4DA7307AC0213542b6838969058469c412555 \
  "transferFrom(address,address,uint256)" \
  $YOUR_ADDRESS \
  $RECIPIENT_ADDRESS \
  1 \
  --rpc-url https://eth-sepolia.public.blastapi.io \
  --private-key $YOUR_PRIVATE_KEY
```

#### 4. Validate at Event

```bash
cast send 0x7CF4DA7307AC0213542b6838969058469c412555 \
  "validateTicket(uint256)" \
  1 \
  --rpc-url https://eth-sepolia.public.blastapi.io \
  --private-key $TICKET_OWNER_PRIVATE_KEY
```

---

## 🔍 Monitoring & Verification

### View on Block Explorers

**Sepolia Etherscan**:
- EventTicket: https://sepolia.etherscan.io/address/0x7CF4DA7307AC0213542b6838969058469c412555
- TicketCallback: https://sepolia.etherscan.io/address/0xE3B386573Af8f8050C7EF24260d2cCcdCE21044d

**Reactive Lasna Scan**:
- Validator: https://lasna.reactscan.net/address/0x0ab8d701f6f45Fe21fA6b63199703ACA121D3Dc8

### Check Validation Results

```bash
# Check if ticket is flagged
cast call 0x0ab8d701f6f45Fe21fA6b63199703ACA121D3Dc8 \
  "suspiciousTickets(uint256)" 1 \
  --rpc-url https://lasna-rpc.rnk.dev/

# Check transfer count
cast call 0x7CF4DA7307AC0213542b6838969058469c412555 \
  "ticketTransferCount(uint256)" 1 \
  --rpc-url https://eth-sepolia.public.blastapi.io
```

---

## 📁 Project Structure

```
A10d/
├── src/                    # Smart contracts
│   ├── EventTicket.sol
│   ├── TicketCallback.sol
│   ├── TicketReactiveValidator.sol
│   └── interfaces/
├── test/                   # Contract tests
│   └── EventTicket.t.sol
├── script/                 # Deployment scripts
│   ├── DeployCallback.s.sol
│   ├── DeployEventTicket.s.sol
│   └── DeployReactiveSimple.s.sol
├── frontend/              # Next.js web app
│   ├── app/
│   │   ├── page.tsx       # Home
│   │   ├── events/        # Browse events
│   │   ├── my-tickets/    # User tickets
│   │   └── create/        # Create event
│   └── lib/
│       ├── contracts.ts   # ABIs & addresses
│       └── wagmi.ts       # Web3 config
├── deploy-all.sh          # Deploy all contracts
├── DEPLOYMENT_SUCCESS.md  # Deployment details
└── FRONTEND_README.md     # Frontend guide
```

---

## 🛡️ Security Considerations

### Smart Contracts
✅ OpenZeppelin libraries for security
✅ Reentrancy protection
✅ Access control (onlyOwner, onlyOrganizer)
✅ Input validation on all functions
⚠️ **Testnet only** - Not audited for mainnet

### Frontend
✅ Type-safe with TypeScript
✅ Secure wallet connection via RainbowKit
✅ Transaction confirmation before execution
✅ Error handling on all contract calls

---

## 🎯 Next Steps

### Immediate
- [ ] Test the full flow: create event → buy ticket → transfer → validate
- [ ] Monitor reactive validator on Reactscan
- [ ] Try transferring tickets to test limits

### Future Enhancements
- [ ] Add event images/thumbnails
- [ ] Implement ticket QR codes
- [ ] Add email notifications
- [ ] Build mobile app
- [ ] Add secondary marketplace
- [ ] Implement Dutch auction for tickets
- [ ] Add event categories and search
- [ ] Integrate IPFS for metadata
- [ ] Add analytics dashboard for organizers

---

## 🔗 Resources

- **Reactive Network Docs**: https://dev.reactive.network/
- **Wagmi Docs**: https://wagmi.sh/
- **RainbowKit Docs**: https://www.rainbowkit.com/
- **Foundry Book**: https://book.getfoundry.sh/
- **Sepolia Faucets**: https://sepoliafaucet.com/

---

## 🎉 Congratulations!

You now have a fully functional decentralized event ticketing platform! 

**Your platform is LIVE at http://localhost:3000** 🚀

- Smart contracts deployed ✅
- Frontend running ✅
- Reactive monitoring active ✅  
- Anti-scalping protection enabled ✅

**Built with ❤️ using Solidity, Next.js, Wagmi, and Reactive Network**
