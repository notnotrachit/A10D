// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title EventTicket
 * @dev NFT-based event ticketing system with anti-scalping and fraud prevention
 * Deployed on origin chain (e.g., Sepolia)
 */
contract EventTicket is ERC721, ERC721URIStorage, Ownable {
    
    uint256 private _tokenIdCounter;
    
    // Event structure
    struct Event {
        string name;
        uint256 maxTickets;
        uint256 ticketsSold;
        uint256 pricePerTicket;
        uint256 eventDate;
        bool active;
        uint256 maxTransfersPerTicket;
        address organizer;
    }
    
    // Ticket transfer tracking for anti-scalping
    mapping(uint256 => uint256) public ticketTransferCount;
    mapping(uint256 => uint256) public ticketEventId;
    mapping(uint256 => Event) public events;
    mapping(uint256 => mapping(address => bool)) public hasAttended;
    mapping(uint256 => address) public originalBuyer;
    
    uint256 public eventCounter;
    uint256 public constant MAX_PRICE_INCREASE = 110; // 110% of original price (10% max increase)
    
    // Events
    event EventCreated(uint256 indexed eventId, string name, uint256 maxTickets, uint256 price);
    event TicketMinted(uint256 indexed tokenId, uint256 indexed eventId, address indexed buyer);
    event TicketTransferred(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to,
        uint256 transferCount,
        uint256 eventId
    );
    event TicketValidated(uint256 indexed tokenId, address indexed holder);
    event PriceViolation(uint256 indexed tokenId, uint256 attemptedPrice, uint256 maxAllowedPrice);
    
    constructor() ERC721("A10D Event Ticket", "A10D") Ownable(msg.sender) {}
    
    /**
     * @dev Create a new event
     */
    function createEvent(
        string memory _name,
        uint256 _maxTickets,
        uint256 _pricePerTicket,
        uint256 _eventDate,
        uint256 _maxTransfersPerTicket
    ) external returns (uint256) {
        require(_maxTickets > 0, "Max tickets must be greater than 0");
        require(_eventDate > block.timestamp, "Event date must be in the future");
        require(_maxTransfersPerTicket > 0, "Max transfers must be greater than 0");
        
        eventCounter++;
        events[eventCounter] = Event({
            name: _name,
            maxTickets: _maxTickets,
            ticketsSold: 0,
            pricePerTicket: _pricePerTicket,
            eventDate: _eventDate,
            active: true,
            maxTransfersPerTicket: _maxTransfersPerTicket,
            organizer: msg.sender
        });
        
        emit EventCreated(eventCounter, _name, _maxTickets, _pricePerTicket);
        return eventCounter;
    }
    
    /**
     * @dev Mint a new ticket for an event
     */
    function mintTicket(uint256 _eventId, string memory _tokenURI) external payable returns (uint256) {
        Event storage eventData = events[_eventId];
        require(eventData.active, "Event is not active");
        require(eventData.ticketsSold < eventData.maxTickets, "Event sold out");
        require(msg.value >= eventData.pricePerTicket, "Insufficient payment");
        require(block.timestamp < eventData.eventDate, "Event has already occurred");
        
        uint256 newTokenId = ++_tokenIdCounter;
        
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        
        ticketEventId[newTokenId] = _eventId;
        originalBuyer[newTokenId] = msg.sender;
        eventData.ticketsSold++;
        
        // Transfer payment to event organizer
        payable(eventData.organizer).transfer(msg.value);
        
        emit TicketMinted(newTokenId, _eventId, msg.sender);
        return newTokenId;
    }
    
    /**
     * @dev Override transfer to implement anti-scalping measures
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);
        
        // If this is not a mint operation (from != address(0)) and not a burn (to != address(0))
        if (from != address(0) && to != address(0)) {
            uint256 eventId = ticketEventId[tokenId];
            Event storage eventData = events[eventId];
            
            // Check transfer count
            require(
                ticketTransferCount[tokenId] < eventData.maxTransfersPerTicket,
                "Ticket has exceeded maximum transfer limit"
            );
            
            ticketTransferCount[tokenId]++;
            
            emit TicketTransferred(tokenId, from, to, ticketTransferCount[tokenId], eventId);
        }
        
        return super._update(to, tokenId, auth);
    }
    
    /**
     * @dev Validate ticket at event entrance
     */
    function validateTicket(uint256 _tokenId) external {
        uint256 eventId = ticketEventId[_tokenId];
        Event storage eventData = events[eventId];
        
        require(eventData.active, "Event is not active");
        require(ownerOf(_tokenId) == msg.sender, "You are not the ticket holder");
        require(!hasAttended[_tokenId][msg.sender], "Ticket already used");
        require(block.timestamp <= eventData.eventDate + 1 days, "Event validation period expired");
        
        hasAttended[_tokenId][msg.sender] = true;
        
        emit TicketValidated(_tokenId, msg.sender);
    }
    
    /**
     * @dev Check if a price is valid (anti-scalping)
     */
    function isPriceValid(uint256 _tokenId, uint256 _salePrice) external view returns (bool) {
        uint256 eventId = ticketEventId[_tokenId];
        Event storage eventData = events[eventId];
        
        uint256 maxAllowedPrice = (eventData.pricePerTicket * MAX_PRICE_INCREASE) / 100;
        return _salePrice <= maxAllowedPrice;
    }
    
    /**
     * @dev Get ticket information
     */
    function getTicketInfo(uint256 _tokenId) external view returns (
        uint256 eventId,
        address owner,
        uint256 transferCount,
        address originalOwner,
        bool isValid
    ) {
        eventId = ticketEventId[_tokenId];
        owner = ownerOf(_tokenId);
        transferCount = ticketTransferCount[_tokenId];
        originalOwner = originalBuyer[_tokenId];
        isValid = events[eventId].active;
    }
    
    /**
     * @dev Get event information
     */
    function getEventInfo(uint256 _eventId) external view returns (
        string memory name,
        uint256 maxTickets,
        uint256 ticketsSold,
        uint256 pricePerTicket,
        uint256 eventDate,
        bool active
    ) {
        Event storage eventData = events[_eventId];
        return (
            eventData.name,
            eventData.maxTickets,
            eventData.ticketsSold,
            eventData.pricePerTicket,
            eventData.eventDate,
            eventData.active
        );
    }
    
    /**
     * @dev Toggle event active status (only organizer)
     */
    function toggleEventStatus(uint256 _eventId) external {
        require(events[_eventId].organizer == msg.sender, "Only organizer can toggle status");
        events[_eventId].active = !events[_eventId].active;
    }
    
    // Required overrides
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
