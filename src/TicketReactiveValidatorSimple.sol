// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./interfaces/IReactive.sol";
import "./interfaces/ISubscriptionService.sol";

/**
 * @title TicketReactiveValidatorSimple
 * @dev Reactive Smart Contract without automatic subscription in constructor
 * Subscribe manually after deployment
 */
contract TicketReactiveValidatorSimple is IReactive {
    
    // System contract for subscription management
    address private constant REACTIVE_SYSTEM_CONTRACT = 0x0000000000000000000000000000000000fffFfF;
    
    address public owner;
    uint256 public originChainId;
    uint256 public destinationChainId;
    address public originContract; // EventTicket contract
    address public callbackContract; // TicketCallback contract
    
    // Event signatures to monitor
    uint256 private constant TICKET_TRANSFERRED_TOPIC = 
        uint256(keccak256("TicketTransferred(uint256,address,address,uint256,uint256)"));
    uint256 private constant TICKET_MINTED_TOPIC = 
        uint256(keccak256("TicketMinted(uint256,uint256,address)"));
    uint256 private constant PRICE_VIOLATION_TOPIC = 
        uint256(keccak256("PriceViolation(uint256,uint256,uint256)"));
    
    // Reactive constants
    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;
    
    // Validation state
    mapping(uint256 => uint256) public ticketTransferCounts;
    mapping(uint256 => address) public ticketCurrentOwner;
    mapping(uint256 => bool) public suspiciousTickets;
    
    // Events
    event TicketTransferMonitored(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to,
        uint256 transferCount
    );
    event ValidationResultSent(uint256 indexed tokenId, bool isValid, string reason);
    event ScalpingAttemptDetected(uint256 indexed tokenId, address scalper);
    event ReactiveCallback(address indexed sender, bytes data);
    event SubscriptionCreated(uint256 chainId, address contractAddr, uint256 topic);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }
    
    modifier onlySystem() {
        require(msg.sender == REACTIVE_SYSTEM_CONTRACT, "Only system contract can call");
        _;
    }
    
    constructor(
        address _systemContract,
        uint256 _originChainId,
        uint256 _destinationChainId,
        address _originContract,
        address _callbackContract
    ) payable {
        require(_originContract != address(0), "Invalid origin contract");
        require(_callbackContract != address(0), "Invalid callback contract");
        
        owner = msg.sender;
        originChainId = _originChainId;
        destinationChainId = _destinationChainId;
        originContract = _originContract;
        callbackContract = _callbackContract;
        
        // NO AUTOMATIC SUBSCRIPTION - do it manually after deployment
    }
    
    /**
     * @dev Manually subscribe to events - call this after deployment
     */
    function subscribeToEvents() external onlyOwner {
        // Subscribe to TicketTransferred events
        ISubscriptionService(REACTIVE_SYSTEM_CONTRACT).subscribe(
            originChainId,
            originContract,
            TICKET_TRANSFERRED_TOPIC,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        emit SubscriptionCreated(originChainId, originContract, TICKET_TRANSFERRED_TOPIC);
        
        // Subscribe to TicketMinted events
        ISubscriptionService(REACTIVE_SYSTEM_CONTRACT).subscribe(
            originChainId,
            originContract,
            TICKET_MINTED_TOPIC,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        emit SubscriptionCreated(originChainId, originContract, TICKET_MINTED_TOPIC);
        
        // Subscribe to PriceViolation events
        ISubscriptionService(REACTIVE_SYSTEM_CONTRACT).subscribe(
            originChainId,
            originContract,
            PRICE_VIOLATION_TOPIC,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        emit SubscriptionCreated(originChainId, originContract, PRICE_VIOLATION_TOPIC);
    }
    
    /**
     * @dev React to events from origin chain
     */
    function react(
        uint256 chain_id,
        address _contract,
        uint256 topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3,
        bytes calldata data,
        uint256 /* block_number */,
        uint256 /* op_code */
    ) external onlySystem {
        emit ReactiveCallback(_contract, data);
        
        if (topic_0 == TICKET_TRANSFERRED_TOPIC) {
            _handleTicketTransfer(topic_1, topic_2, topic_3, data);
        } else if (topic_0 == TICKET_MINTED_TOPIC) {
            _handleTicketMinted(topic_1, topic_2, topic_3, data);
        } else if (topic_0 == PRICE_VIOLATION_TOPIC) {
            _handlePriceViolation(topic_1, data);
        }
    }
    
    function _handleTicketTransfer(
        uint256 topic_1, // tokenId (indexed)
        uint256 topic_2, // from address (indexed)
        uint256 topic_3, // to address (indexed)
        bytes calldata data
    ) private {
        uint256 tokenId = topic_1;
        address from = address(uint160(topic_2));
        address to = address(uint160(topic_3));
        
        // Decode non-indexed parameters from data
        (uint256 transferCount, uint256 maxTransfers) = abi.decode(data, (uint256, uint256));
        
        // Update state
        ticketTransferCounts[tokenId] = transferCount;
        ticketCurrentOwner[tokenId] = to;
        
        emit TicketTransferMonitored(tokenId, from, to, transferCount);
        
        // Validate transfer
        bool isValid = transferCount <= maxTransfers;
        string memory reason = isValid ? "Valid transfer" : "Exceeded max transfers";
        
        if (!isValid) {
            suspiciousTickets[tokenId] = true;
            emit ScalpingAttemptDetected(tokenId, to);
        }
        
        // Send callback to destination chain
        _sendCallback(tokenId, from, to, transferCount, isValid, reason);
        
        emit ValidationResultSent(tokenId, isValid, reason);
    }
    
    function _handleTicketMinted(
        uint256 topic_1, // tokenId (indexed)
        uint256 topic_2, // eventId (indexed)
        uint256 topic_3, // buyer (indexed)
        bytes calldata /* data */
    ) private {
        uint256 tokenId = topic_1;
        address buyer = address(uint160(topic_3));
        
        // Initialize tracking
        ticketTransferCounts[tokenId] = 0;
        ticketCurrentOwner[tokenId] = buyer;
    }
    
    function _handlePriceViolation(
        uint256 topic_1, // tokenId (indexed)
        bytes calldata /* data */
    ) private {
        uint256 tokenId = topic_1;
        suspiciousTickets[tokenId] = true;
        
        address currentOwner = ticketCurrentOwner[tokenId];
        emit ScalpingAttemptDetected(tokenId, currentOwner);
    }
    
    function _sendCallback(
        uint256 tokenId,
        address from,
        address to,
        uint256 transferCount,
        bool isValid,
        string memory reason
    ) private {
        bytes memory payload = abi.encodeWithSignature(
            "receiveTransferValidation(uint256,address,address,uint256,bool,string)",
            tokenId,
            from,
            to,
            transferCount,
            isValid,
            reason
        );
        
        emit ReactiveCallback(callbackContract, payload);
    }
    
    // Admin functions
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
    receive() external payable {}
}
