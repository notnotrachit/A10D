# A10D Architecture Documentation

## System Overview

A10D is a decentralized event ticketing system built on the Reactive Network that prevents fraud and scalping through autonomous cross-chain validation.

## Core Components

### 1. EventTicket.sol (Origin Chain)

**Purpose**: NFT-based ticketing system with built-in anti-scalping measures

**Key Features**:
- ERC-721 compliant NFTs representing event tickets
- Event creation and management
- Ticket minting with payment handling
- Transfer limit enforcement
- Price validation mechanism
- Ticket validation for event entry

**State Variables**:
```solidity
- events: mapping(uint256 => Event)
- ticketTransferCount: mapping(uint256 => uint256)
- ticketEventId: mapping(uint256 => uint256)
- originalBuyer: mapping(uint256 => address)
- hasAttended: mapping(uint256 => mapping(address => bool))
```

**Events Emitted**:
- `EventCreated(uint256 eventId, string name, uint256 maxTickets, uint256 price)`
- `TicketMinted(uint256 tokenId, uint256 eventId, address buyer)`
- `TicketTransferred(uint256 tokenId, address from, address to, uint256 transferCount, uint256 eventId)`
- `TicketValidated(uint256 tokenId, address holder)`
- `PriceViolation(uint256 tokenId, uint256 attemptedPrice, uint256 maxAllowedPrice)`

### 2. TicketReactiveValidator.sol (Reactive Network)

**Purpose**: Autonomous monitoring and validation of ticket operations

**Key Features**:
- Subscribes to events from EventTicket contract
- Monitors ticket transfers in real-time
- Validates transfers against business rules
- Detects scalping attempts
- Sends validation callbacks to destination chain

**Subscriptions**:
1. `TicketTransferred` events
2. `TicketMinted` events
3. `PriceViolation` events

**Validation Logic**:
- Transfer count validation (excessive transfers = suspicious)
- Address blacklist checking
- Pattern detection for fraud

**Cross-Chain Communication**:
- Uses Reactive Network's callback mechanism
- Sends validation results to TicketCallback contract
- Encodes data for callback execution

### 3. TicketCallback.sol (Destination Chain)

**Purpose**: Receives and records validation results from Reactive Network

**Key Features**:
- Receives callbacks from reactive contract
- Maintains transfer history for all tickets
- Flags suspicious tickets
- Manages blacklist of malicious addresses
- Tracks suspicious activity counts

**State Variables**:
```solidity
- transferHistory: mapping(uint256 => TransferValidation[])
- flaggedTickets: mapping(uint256 => bool)
- blacklistedAddresses: mapping(address => bool)
- suspiciousActivityCount: mapping(uint256 => uint256)
```

**Events Emitted**:
- `TransferValidated(uint256 tokenId, address from, address to, bool isValid, string reason)`
- `TicketFlagged(uint256 tokenId, string reason)`
- `AddressBlacklisted(address account, string reason)`
- `ScalpingDetected(uint256 tokenId, address scalper)`

## Data Flow

### Ticket Purchase Flow

```
1. User calls EventTicket.mintTicket()
   ↓
2. EventTicket mints NFT and emits TicketMinted event
   ↓
3. TicketReactiveValidator.react() is triggered by Reactive Network
   ↓
4. Reactive contract initializes tracking for the new ticket
   ↓
5. (Optional) Callback sent to TicketCallback for record-keeping
```

### Ticket Transfer Flow

```
1. User calls EventTicket.transferFrom()
   ↓
2. EventTicket validates transfer count < max allowed
   ↓
3. Transfer executes, TicketTransferred event emitted
   ↓
4. Reactive Network detects event and calls TicketReactiveValidator.react()
   ↓
5. TicketReactiveValidator validates the transfer:
   - Checks transfer count
   - Checks for suspicious patterns
   - Validates against blacklist
   ↓
6. TicketReactiveValidator sends callback to TicketCallback
   ↓
7. TicketCallback records validation result:
   - Updates transfer history
   - Flags ticket if invalid
   - Blacklists addresses if needed
   ↓
8. Events emitted for tracking
```

### Scalping Detection Flow

```
1. Scalper attempts to list ticket at inflated price
   ↓
2. Platform/marketplace calls EventTicket.isPriceValid()
   ↓
3. If price > 110% original, validation fails
   ↓
4. PriceViolation event emitted
   ↓
5. TicketReactiveValidator.react() triggered
   ↓
6. Reactive contract sends scalping alert to TicketCallback
   ↓
7. TicketCallback:
   - Flags the ticket
   - Blacklists the scalper
   - Increments suspicious activity count
```

## Anti-Scalping Mechanisms

### 1. Transfer Limits

Each ticket has a configurable maximum transfer count:
- Set by event organizer during event creation
- Enforced on-chain in EventTicket._update()
- Prevents excessive ticket flipping
- Typical limit: 2-3 transfers

### 2. Price Caps

Maximum resale price enforcement:
- Hard cap at 110% of original price
- Validated through EventTicket.isPriceValid()
- Can be checked by marketplaces before listing
- Violations trigger PriceViolation events

### 3. Automatic Blacklisting

Progressive enforcement:
- 1st violation: Ticket flagged
- 2nd violation: Ticket flagged, warning recorded
- 3rd violation: Address blacklisted permanently

Blacklist effects:
- Tracked on TicketCallback contract
- Can be queried by marketplaces
- Prevents repeat offenders

### 4. Real-Time Monitoring

Reactive Network advantages:
- 24/7 autonomous monitoring
- No manual intervention required
- Cross-chain coordination
- Low latency validation (seconds)

## Security Considerations

### Access Control

**EventTicket.sol**:
- `onlyOwner`: Contract deployment and configuration
- Event organizers: Can toggle their event status
- Anyone: Can mint tickets (with payment)

**TicketCallback.sol**:
- `onlyCallbackSender`: Only reactive contract can send callbacks
- `onlyOwner`: Manual flagging and blacklist management

**TicketReactiveValidator.sol**:
- `onlyOwner`: Configuration updates
- `onlySystem`: Only Reactive Network can call react()

### Reentrancy Protection

- Uses OpenZeppelin's battle-tested contracts
- ERC-721 includes reentrancy guards
- Payment transfers use simple `.transfer()` calls

### Integer Overflow

- Solidity 0.8.26 includes built-in overflow protection
- No need for SafeMath

### Front-Running

Mitigation strategies:
- Ticket purchases are first-come-first-served
- Transfer validation happens post-transaction
- No MEV opportunities in validation logic

## Gas Optimization

### EventTicket.sol
- Uses `Counters` library for efficient ID generation
- Minimal storage operations
- Events for off-chain indexing instead of storage

### TicketReactiveValidator.sol
- Lightweight validation logic
- Event emissions for tracking (cheaper than storage)
- Batching not needed due to Reactive Network architecture

### TicketCallback.sol
- Efficient storage patterns
- Array length limits considered
- Events for off-chain indexing

## Scalability

### Current Limitations

- Transfer history arrays can grow unbounded
- Should implement pagination for large datasets
- Consider archival solutions for old events

### Future Improvements

1. **Merkle Tree Storage**
   - Store transfer history in Merkle trees
   - Reduce on-chain storage costs
   - Enable efficient proofs

2. **Event Archival**
   - Archive old events to IPFS/Arweave
   - Keep only recent data on-chain
   - Reduce state bloat

3. **Layer 2 Integration**
   - Deploy on L2s for lower gas costs
   - Use Reactive Network for L1 ↔ L2 coordination

## Integration Guide

### For Event Organizers

```solidity
// 1. Deploy EventTicket or use existing deployment
EventTicket ticket = EventTicket(TICKET_ADDRESS);

// 2. Create your event
uint256 eventId = ticket.createEvent(
    "My Event",
    1000,              // max tickets
    0.1 ether,         // price
    timestamp + 30 days, // date
    3                  // max transfers
);

// 3. Share the contract address and event ID
// 4. Tickets are automatically monitored by reactive contract
```

### For Marketplaces

```solidity
// Before allowing a listing, check:

// 1. Is the ticket flagged?
bool flagged = callback.isTicketFlagged(tokenId);

// 2. Is the seller blacklisted?
bool blacklisted = callback.isAddressBlacklisted(seller);

// 3. Is the price valid?
bool priceOk = ticket.isPriceValid(tokenId, askingPrice);

// 4. Only allow listing if all checks pass
require(!flagged && !blacklisted && priceOk, "Invalid listing");
```

### For Ticket Buyers

```solidity
// Buy directly from EventTicket
ticket.mintTicket{value: price}(eventId, metadata);

// Or buy from secondary market (after marketplace validates)
marketplace.buyTicket(listingId);
```

## Monitoring & Analytics

### Key Metrics to Track

1. **Transfer Statistics**
   - Average transfers per ticket
   - Distribution of transfer counts
   - Percentage of tickets hitting transfer limit

2. **Violation Metrics**
   - Number of flagged tickets
   - Number of blacklisted addresses
   - Most common violation reasons

3. **Event Success**
   - Tickets sold vs. max tickets
   - Validation rate at event entrance
   - No-show percentage

### Querying Transfer History

```solidity
// Get all transfers for a ticket
TransferValidation[] memory history = callback.getTransferHistory(tokenId);

// Check suspicious activity
uint256 violations = callback.getSuspiciousActivityCount(tokenId);
```

## Deployment Checklist

- [ ] Configure .env with correct RPC URLs
- [ ] Fund deployer addresses with test/real ETH
- [ ] Get Reactive Network system contract addresses
- [ ] Deploy TicketCallback to destination chain
- [ ] Deploy EventTicket to origin chain
- [ ] Deploy TicketReactiveValidator with correct addresses
- [ ] Verify all contracts on block explorers
- [ ] Test ticket purchase flow
- [ ] Test ticket transfer flow
- [ ] Verify reactive monitoring is working
- [ ] Check callback execution

## Troubleshooting

### Callbacks Not Received

Check:
1. Reactive contract has sufficient balance
2. Callback sender address is correct
3. Destination chain is supported by Reactive Network
4. System contract address is correct

### Validation Not Triggering

Check:
1. Events are being emitted from EventTicket
2. Subscription topics match event signatures
3. Reactive contract has enough gas
4. Origin chain ID is correct

### Tests Failing

Check:
1. All dependencies installed (`forge install`)
2. Correct Solidity version (0.8.26)
3. Remappings configured correctly
4. forge-std version compatible

---

For more information, see:
- [README.md](./README.md)
- [QUICKSTART.md](./QUICKSTART.md)
- [Reactive Network Docs](https://dev.reactive.network/)
