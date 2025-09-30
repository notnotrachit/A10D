# A10D Troubleshooting Guide

Common issues and their solutions.

## Installation Issues

### Foundry Not Found

**Problem**: `forge: command not found`

**Solution**:
```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash

# Reload shell
source ~/.bashrc  # or ~/.zshrc for zsh

# Install/update Foundry tools
foundryup
```

### OpenZeppelin Import Errors

**Problem**: `Error: Could not find openzeppelin/contracts`

**Solution**:
```bash
# Install OpenZeppelin
forge install OpenZeppelin/openzeppelin-contracts --no-commit

# Verify remappings.txt exists
cat remappings.txt

# Should contain:
# @openzeppelin/=lib/openzeppelin-contracts/
```

### Compilation Errors

**Problem**: Compilation fails with version errors

**Solution**:
```bash
# Check Solidity version in foundry.toml
# Should be 0.8.26

# Clean and rebuild
forge clean
forge build
```

## Deployment Issues

### Insufficient Funds

**Problem**: `Error: insufficient funds for gas * price + value`

**Solution**:
- Get test ETH from faucets:
  - Sepolia: https://sepoliafaucet.com/
  - Reactive Kopli: https://dev.reactive.network/docs/kopli-testnet
- Ensure you have:
  - Origin chain: ~0.5 ETH
  - Destination chain: ~0.5 ETH
  - Reactive Network: ~1 ETH

### Invalid Callback Sender

**Problem**: `Error: Invalid callback sender`

**Solution**:
1. Verify you're using the correct callback proxy address
2. Check Reactive Network documentation for current addresses:
   - Kopli Testnet: https://dev.reactive.network/docs/kopli-testnet
   - Mainnet: https://dev.reactive.network/docs/mainnet

### Transaction Reverted

**Problem**: Transaction reverts during deployment

**Solution**:
```bash
# Check transaction with verbose output
cast tx <TX_HASH> --rpc-url $ORIGIN_RPC

# View receipt
cast receipt <TX_HASH> --rpc-url $ORIGIN_RPC

# Try with more gas
forge create ... --gas-limit 5000000
```

## Runtime Issues

### Events Not Being Monitored

**Problem**: Reactive contract not triggering on ticket transfers

**Solution**:
1. Verify reactive contract has sufficient balance:
```bash
cast balance $TICKET_REACTIVE_ADDR --rpc-url $REACTIVE_RPC
```

2. Check if subscriptions are active:
```bash
# View logs from reactive contract deployment
# Should show subscription confirmations
```

3. Verify event signature matches:
```bash
# Calculate event signature
cast keccak "TicketTransferred(uint256,address,address,uint256,uint256)"
# Should match TICKET_TRANSFERRED_TOPIC in contract
```

### Callbacks Not Received

**Problem**: TicketCallback not receiving validation results

**Solution**:
1. Check callback contract balance:
```bash
cast balance $TICKET_CALLBACK_ADDR --rpc-url $DESTINATION_RPC
```

2. Verify callback sender configuration:
```bash
cast call $TICKET_CALLBACK_ADDR "callbackSender()" --rpc-url $DESTINATION_RPC
```

3. Check Reactive Network status:
   - Visit https://kopli.reactscan.net/
   - Verify network is operational

### Price Validation Failing

**Problem**: Valid prices being rejected

**Solution**:
1. Check MAX_PRICE_INCREASE constant (default 110%):
```solidity
// In EventTicket.sol
uint256 public constant MAX_PRICE_INCREASE = 110;
```

2. Calculate expected max price:
```bash
# If ticket was 0.1 ETH
# Max allowed = 0.1 * 1.10 = 0.11 ETH
```

3. Verify with:
```bash
cast call $EVENT_TICKET_ADDR \
  "isPriceValid(uint256,uint256)" \
  <TOKEN_ID> \
  <PRICE_IN_WEI> \
  --rpc-url $ORIGIN_RPC
```

### Transfer Limit Exceeded

**Problem**: Cannot transfer ticket despite being under limit

**Solution**:
1. Check current transfer count:
```bash
cast call $EVENT_TICKET_ADDR \
  "ticketTransferCount(uint256)" \
  <TOKEN_ID> \
  --rpc-url $ORIGIN_RPC
```

2. Check event's max transfer limit:
```bash
cast call $EVENT_TICKET_ADDR \
  "getEventInfo(uint256)" \
  <EVENT_ID> \
  --rpc-url $ORIGIN_RPC
```

3. Verify you haven't hit the limit

## Testing Issues

### Tests Failing

**Problem**: `forge test` fails

**Solution**:
```bash
# Run with verbose output
forge test -vvvv

# Run specific test
forge test --match-test testMintTicket -vvvv

# Check for common issues:
# 1. Insufficient test setup
# 2. Time-dependent tests (use vm.warp)
# 3. Balance issues (use vm.deal)
```

### Fork Testing Issues

**Problem**: Cannot fork mainnet/testnet for testing

**Solution**:
```bash
# Set RPC URL in foundry.toml or .env
# Use a reliable RPC provider (Alchemy, Infura)

# Test with fork
forge test --fork-url $ORIGIN_RPC
```

## Network Issues

### RPC Connection Failed

**Problem**: Cannot connect to RPC endpoint

**Solution**:
1. Verify RPC URL is correct
2. Check if endpoint is operational:
```bash
curl -X POST $ORIGIN_RPC \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

3. Try alternative RPC providers:
   - Alchemy
   - Infura
   - Public endpoints

### Chain ID Mismatch

**Problem**: Wrong chain ID in transactions

**Solution**:
```bash
# Verify chain IDs
cast chain-id --rpc-url $ORIGIN_RPC
cast chain-id --rpc-url $DESTINATION_RPC

# Update .env if needed
ORIGIN_CHAIN_ID=11155111  # Sepolia
DESTINATION_CHAIN_ID=11155111
```

## Contract Interaction Issues

### Function Call Reverted

**Problem**: Contract function call reverts

**Solution**:
```bash
# Call as view function first to check requirements
cast call $EVENT_TICKET_ADDR \
  "mintTicket(uint256,string)" \
  1 \
  "ipfs://test" \
  --rpc-url $ORIGIN_RPC \
  --from <YOUR_ADDRESS>

# Check error message
# Common issues:
# - "Event is not active"
# - "Insufficient payment"
# - "Event sold out"
```

### Cannot Approve Token

**Problem**: ERC-721 approval failing

**Solution**:
```bash
# Verify you own the token
cast call $EVENT_TICKET_ADDR \
  "ownerOf(uint256)" \
  <TOKEN_ID> \
  --rpc-url $ORIGIN_RPC

# Set approval
cast send $EVENT_TICKET_ADDR \
  "approve(address,uint256)" \
  <SPENDER> \
  <TOKEN_ID> \
  --rpc-url $ORIGIN_RPC \
  --private-key $ORIGIN_PRIVATE_KEY
```

## Environment Issues

### .env Variables Not Loading

**Problem**: Environment variables are empty

**Solution**:
```bash
# Verify .env exists
ls -la .env

# Check content
cat .env

# Make sure to source it if using bash scripts
source .env

# For Foundry scripts, it loads automatically
```

### Private Key Issues

**Problem**: Invalid private key format

**Solution**:
```bash
# Private key should:
# - Be 64 hex characters (without 0x prefix)
# - Or 66 characters (with 0x prefix)

# Verify format
echo $ORIGIN_PRIVATE_KEY | wc -c

# Extract address from private key
cast wallet address --private-key $ORIGIN_PRIVATE_KEY
```

## Gas Issues

### Out of Gas

**Problem**: Transaction runs out of gas

**Solution**:
```bash
# Estimate gas first
cast estimate $EVENT_TICKET_ADDR \
  "mintTicket(uint256,string)" \
  1 \
  "ipfs://test" \
  --value 0.1ether \
  --rpc-url $ORIGIN_RPC

# Send with higher gas limit
cast send ... --gas-limit 500000
```

### Gas Price Too Low

**Problem**: Transaction stuck in mempool

**Solution**:
```bash
# Check current gas price
cast gas-price --rpc-url $ORIGIN_RPC

# Send with higher gas price
cast send ... --gas-price 2gwei
```

## Debug Commands

### View Contract State

```bash
# Get storage slot
cast storage $EVENT_TICKET_ADDR <SLOT> --rpc-url $ORIGIN_RPC

# Call view functions
cast call $EVENT_TICKET_ADDR "eventCounter()" --rpc-url $ORIGIN_RPC
```

### View Transaction Details

```bash
# Get transaction
cast tx <TX_HASH> --rpc-url $ORIGIN_RPC

# Get receipt
cast receipt <TX_HASH> --rpc-url $ORIGIN_RPC

# Decode transaction input
cast 4byte-decode <INPUT_DATA>
```

### View Logs

```bash
# Get logs for address
cast logs --address $EVENT_TICKET_ADDR \
  --from-block 0 \
  --to-block latest \
  --rpc-url $ORIGIN_RPC
```

## Getting Help

If you're still experiencing issues:

1. **Check Documentation**
   - README.md
   - ARCHITECTURE.md
   - Reactive Network Docs: https://dev.reactive.network/

2. **Enable Debug Mode**
   ```bash
   export RUST_LOG=debug
   forge test -vvvv
   ```

3. **Search Issues**
   - GitHub Issues
   - Reactive Network Discord
   - Ethereum Stack Exchange

4. **Create Issue**
   - Include error messages
   - Provide transaction hashes
   - Share relevant code snippets
   - Describe steps to reproduce

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `Event is not active` | Event was deactivated | Check event status, contact organizer |
| `Insufficient payment` | Wrong value sent | Check ticket price with `getEventInfo()` |
| `Event sold out` | All tickets minted | Event is at capacity |
| `Ticket has exceeded maximum transfer limit` | Too many transfers | Ticket cannot be transferred anymore |
| `You are not the ticket holder` | Wrong address trying to validate | Must be ticket owner |
| `Ticket already used` | Double validation attempt | Ticket was already validated |
| `Only callback sender can call` | Unauthorized callback | Verify callback sender address |

---

Still having issues? Open an issue on GitHub with:
- Error message
- Command/code that triggered it
- Expected vs actual behavior
- Environment details (OS, Foundry version, etc.)
