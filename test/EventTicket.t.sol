// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/EventTicket.sol";

contract EventTicketTest is Test {
    EventTicket public ticket;
    address public organizer;
    address public buyer;
    address public scalper;
    
    uint256 constant TICKET_PRICE = 0.1 ether;
    uint256 constant MAX_TICKETS = 100;
    uint256 constant MAX_TRANSFERS = 3;
    
    function setUp() public {
        organizer = makeAddr("organizer");
        buyer = makeAddr("buyer");
        scalper = makeAddr("scalper");
        
        vm.deal(organizer, 10 ether);
        vm.deal(buyer, 10 ether);
        vm.deal(scalper, 10 ether);
        
        ticket = new EventTicket();
    }
    
    function testCreateEvent() public {
        vm.startPrank(organizer);
        
        uint256 eventDate = block.timestamp + 7 days;
        uint256 eventId = ticket.createEvent(
            "Web3 Conference 2025",
            MAX_TICKETS,
            TICKET_PRICE,
            eventDate,
            MAX_TRANSFERS
        );
        
        assertEq(eventId, 1);
        
        (
            string memory name,
            uint256 maxTickets,
            uint256 ticketsSold,
            uint256 price,
            uint256 date,
            bool active
        ) = ticket.getEventInfo(eventId);
        
        assertEq(name, "Web3 Conference 2025");
        assertEq(maxTickets, MAX_TICKETS);
        assertEq(ticketsSold, 0);
        assertEq(price, TICKET_PRICE);
        assertEq(date, eventDate);
        assertTrue(active);
        
        vm.stopPrank();
    }
    
    function testMintTicket() public {
        // Create event
        vm.startPrank(organizer);
        uint256 eventDate = block.timestamp + 7 days;
        uint256 eventId = ticket.createEvent(
            "Web3 Conference 2025",
            MAX_TICKETS,
            TICKET_PRICE,
            eventDate,
            MAX_TRANSFERS
        );
        vm.stopPrank();
        
        // Mint ticket
        vm.startPrank(buyer);
        uint256 tokenId = ticket.mintTicket{value: TICKET_PRICE}(
            eventId,
            "ipfs://QmTicketMetadata"
        );
        vm.stopPrank();
        
        assertEq(tokenId, 1);
        assertEq(ticket.ownerOf(tokenId), buyer);
        
        (
            uint256 ticketEventId,
            address owner,
            uint256 transferCount,
            address originalOwner,
            bool isValid
        ) = ticket.getTicketInfo(tokenId);
        
        assertEq(ticketEventId, eventId);
        assertEq(owner, buyer);
        assertEq(transferCount, 0);
        assertEq(originalOwner, buyer);
        assertTrue(isValid);
    }
    
    function testTransferTicket() public {
        // Setup: Create event and mint ticket
        vm.prank(organizer);
        uint256 eventId = ticket.createEvent(
            "Web3 Conference 2025",
            MAX_TICKETS,
            TICKET_PRICE,
            block.timestamp + 7 days,
            MAX_TRANSFERS
        );
        
        vm.prank(buyer);
        uint256 tokenId = ticket.mintTicket{value: TICKET_PRICE}(
            eventId,
            "ipfs://QmTicketMetadata"
        );
        
        // Transfer ticket
        vm.prank(buyer);
        ticket.transferFrom(buyer, scalper, tokenId);
        
        assertEq(ticket.ownerOf(tokenId), scalper);
        assertEq(ticket.ticketTransferCount(tokenId), 1);
    }
    
    function test_RevertWhen_ExcessiveTransfers() public {
        // Setup
        vm.prank(organizer);
        uint256 eventId = ticket.createEvent(
            "Web3 Conference 2025",
            MAX_TICKETS,
            TICKET_PRICE,
            block.timestamp + 7 days,
            2 // Only 2 transfers allowed
        );
        
        vm.prank(buyer);
        uint256 tokenId = ticket.mintTicket{value: TICKET_PRICE}(
            eventId,
            "ipfs://QmTicketMetadata"
        );
        
        // Transfer 1
        vm.prank(buyer);
        ticket.transferFrom(buyer, address(0x4), tokenId);
        
        // Transfer 2
        vm.prank(address(0x4));
        ticket.transferFrom(address(0x4), address(0x5), tokenId);
        
        // Transfer 3 - should fail
        vm.expectRevert("Ticket has exceeded maximum transfer limit");
        vm.prank(address(0x5));
        ticket.transferFrom(address(0x5), scalper, tokenId);
    }
    
    function testValidateTicket() public {
        // Setup
        vm.prank(organizer);
        uint256 eventId = ticket.createEvent(
            "Web3 Conference 2025",
            MAX_TICKETS,
            TICKET_PRICE,
            block.timestamp + 7 days,
            MAX_TRANSFERS
        );
        
        vm.prank(buyer);
        uint256 tokenId = ticket.mintTicket{value: TICKET_PRICE}(
            eventId,
            "ipfs://QmTicketMetadata"
        );
        
        // Fast forward to event date
        vm.warp(block.timestamp + 7 days);
        
        // Validate ticket
        vm.prank(buyer);
        ticket.validateTicket(tokenId);
        
        assertTrue(ticket.hasAttended(tokenId, buyer));
    }
    
    function test_RevertWhen_DoubleValidation() public {
        // Setup
        vm.prank(organizer);
        uint256 eventId = ticket.createEvent(
            "Web3 Conference 2025",
            MAX_TICKETS,
            TICKET_PRICE,
            block.timestamp + 7 days,
            MAX_TRANSFERS
        );
        
        vm.prank(buyer);
        uint256 tokenId = ticket.mintTicket{value: TICKET_PRICE}(
            eventId,
            "ipfs://QmTicketMetadata"
        );
        
        vm.warp(block.timestamp + 7 days);
        
        // First validation
        vm.prank(buyer);
        ticket.validateTicket(tokenId);
        
        // Second validation - should fail
        vm.expectRevert("Ticket already used");
        vm.prank(buyer);
        ticket.validateTicket(tokenId);
    }
    
    function testPriceValidation() public {
        // Setup
        vm.prank(organizer);
        uint256 eventId = ticket.createEvent(
            "Web3 Conference 2025",
            MAX_TICKETS,
            TICKET_PRICE,
            block.timestamp + 7 days,
            MAX_TRANSFERS
        );
        
        vm.prank(buyer);
        uint256 tokenId = ticket.mintTicket{value: TICKET_PRICE}(
            eventId,
            "ipfs://QmTicketMetadata"
        );
        
        // Valid price (10% increase)
        uint256 validPrice = 0.11 ether;
        assertTrue(ticket.isPriceValid(tokenId, validPrice));
        
        // Invalid price (20% increase)
        uint256 invalidPrice = 0.12 ether;
        assertFalse(ticket.isPriceValid(tokenId, invalidPrice));
    }
    
    function test_RevertWhen_MintAfterSoldOut() public {
        // Create small event
        vm.prank(organizer);
        uint256 eventId = ticket.createEvent(
            "Small Event",
            1, // Only 1 ticket
            TICKET_PRICE,
            block.timestamp + 7 days,
            MAX_TRANSFERS
        );
        
        // Mint first ticket
        vm.prank(buyer);
        ticket.mintTicket{value: TICKET_PRICE}(eventId, "ipfs://ticket1");
        
        // Try to mint second ticket - should fail
        vm.expectRevert("Event sold out");
        vm.prank(scalper);
        ticket.mintTicket{value: TICKET_PRICE}(eventId, "ipfs://ticket2");
    }
}
