#!/bin/bash

# A10D Interaction Script
# Helper scripts for interacting with deployed contracts

source .env

echo "========================================"
echo "   A10D Contract Interaction Helper"
echo "========================================"
echo ""

# Function to create an event
create_event() {
    echo "Creating a new event..."
    
    EVENT_NAME="Web3 Conference 2025"
    MAX_TICKETS=100
    PRICE_WEI=100000000000000000  # 0.1 ETH
    EVENT_DATE=$(($(date +%s) + 2592000))  # 30 days from now
    MAX_TRANSFERS=3
    
    cast send $EVENT_TICKET_ADDR \
        "createEvent(string,uint256,uint256,uint256,uint256)" \
        "$EVENT_NAME" \
        $MAX_TICKETS \
        $PRICE_WEI \
        $EVENT_DATE \
        $MAX_TRANSFERS \
        --rpc-url $ORIGIN_RPC \
        --private-key $ORIGIN_PRIVATE_KEY
    
    echo "✅ Event created!"
}

# Function to mint a ticket
mint_ticket() {
    echo "Minting a ticket for event ID: $1"
    
    EVENT_ID=$1
    TOKEN_URI="ipfs://QmExample123"
    
    cast send $EVENT_TICKET_ADDR \
        "mintTicket(uint256,string)" \
        $EVENT_ID \
        "$TOKEN_URI" \
        --value 0.1ether \
        --rpc-url $ORIGIN_RPC \
        --private-key $ORIGIN_PRIVATE_KEY
    
    echo "✅ Ticket minted!"
}

# Function to get event info
get_event_info() {
    echo "Getting info for event ID: $1"
    
    cast call $EVENT_TICKET_ADDR \
        "getEventInfo(uint256)" \
        $1 \
        --rpc-url $ORIGIN_RPC
}

# Function to get ticket info
get_ticket_info() {
    echo "Getting info for ticket ID: $1"
    
    cast call $EVENT_TICKET_ADDR \
        "getTicketInfo(uint256)" \
        $1 \
        --rpc-url $ORIGIN_RPC
}

# Function to check if ticket is flagged
check_flagged() {
    echo "Checking if ticket ID $1 is flagged..."
    
    cast call $TICKET_CALLBACK_ADDR \
        "isTicketFlagged(uint256)" \
        $1 \
        --rpc-url $DESTINATION_RPC
}

# Function to check if address is blacklisted
check_blacklisted() {
    echo "Checking if address $1 is blacklisted..."
    
    cast call $TICKET_CALLBACK_ADDR \
        "isAddressBlacklisted(address)" \
        $1 \
        --rpc-url $DESTINATION_RPC
}

# Function to get transfer history
get_transfer_history() {
    echo "Getting transfer history for ticket ID: $1"
    
    cast call $TICKET_CALLBACK_ADDR \
        "getTransferHistory(uint256)" \
        $1 \
        --rpc-url $DESTINATION_RPC
}

# Function to get reactive contract status
get_reactive_status() {
    echo "Getting reactive contract status for ticket ID: $1"
    
    cast call $TICKET_REACTIVE_ADDR \
        "getTicketStatus(uint256)" \
        $1 \
        --rpc-url $REACTIVE_RPC
}

# Function to transfer ticket
transfer_ticket() {
    echo "Transferring ticket ID $1 to address $2"
    
    cast send $EVENT_TICKET_ADDR \
        "transferFrom(address,address,uint256)" \
        $(cast wallet address --private-key $ORIGIN_PRIVATE_KEY) \
        $2 \
        $1 \
        --rpc-url $ORIGIN_RPC \
        --private-key $ORIGIN_PRIVATE_KEY
    
    echo "✅ Ticket transferred!"
}

# Function to validate ticket at event
validate_ticket() {
    echo "Validating ticket ID: $1"
    
    cast send $EVENT_TICKET_ADDR \
        "validateTicket(uint256)" \
        $1 \
        --rpc-url $ORIGIN_RPC \
        --private-key $ORIGIN_PRIVATE_KEY
    
    echo "✅ Ticket validated!"
}

# Menu
case "$1" in
    create-event)
        create_event
        ;;
    mint)
        mint_ticket $2
        ;;
    event-info)
        get_event_info $2
        ;;
    ticket-info)
        get_ticket_info $2
        ;;
    check-flagged)
        check_flagged $2
        ;;
    check-blacklisted)
        check_blacklisted $2
        ;;
    transfer-history)
        get_transfer_history $2
        ;;
    reactive-status)
        get_reactive_status $2
        ;;
    transfer)
        transfer_ticket $2 $3
        ;;
    validate)
        validate_ticket $2
        ;;
    *)
        echo "Usage: $0 {command} [args]"
        echo ""
        echo "Commands:"
        echo "  create-event                    - Create a new event"
        echo "  mint {eventId}                  - Mint a ticket for an event"
        echo "  event-info {eventId}            - Get event information"
        echo "  ticket-info {tokenId}           - Get ticket information"
        echo "  check-flagged {tokenId}         - Check if ticket is flagged"
        echo "  check-blacklisted {address}     - Check if address is blacklisted"
        echo "  transfer-history {tokenId}      - Get ticket transfer history"
        echo "  reactive-status {tokenId}       - Get reactive contract status"
        echo "  transfer {tokenId} {toAddress}  - Transfer ticket to address"
        echo "  validate {tokenId}              - Validate ticket at event"
        echo ""
        exit 1
        ;;
esac
