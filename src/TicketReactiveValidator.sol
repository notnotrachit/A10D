// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./interfaces/IReactive.sol";
import "./interfaces/ISubscriptionService.sol";

/**
 * @title TicketReactiveValidator
 * @dev Reactive Smart Contract that monitors ticket transfers across chains
 * and autonomously validates them to prevent fraud and scalping
 * Deployed on Reactive Network (Kopli testnet or mainnet)
 */
contract TicketReactiveValidator is IReactive {
    
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
        
        // Subscribe to TicketTransferred events
        ISubscriptionService(REACTIVE_SYSTEM_CONTRACT).subscribe(
            _originChainId,
            _originContract,
            TICKET_TRANSFERRED_TOPIC,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        
        // Subscribe to TicketMinted events
        ISubscriptionService(REACTIVE_SYSTEM_CONTRACT).subscribe(
            _originChainId,
            _originContract,
            TICKET_MINTED_TOPIC,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        
        // Subscribe to PriceViolation events
        ISubscriptionService(REACTIVE_SYSTEM_CONTRACT).subscribe(
            _originChainId,
            _originContract,
            PRICE_VIOLATION_TOPIC,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
    }
    
    /**
     * @dev Main reactive function called by Reactive Network when subscribed events occur
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
    ) external override onlySystem {
        
        // Ensure event is from the correct chain and contract
        if (chain_id != originChainId || _contract != originContract) {
            return;
        }
        
        // Handle TicketTransferred event
        if (topic_0 == uint256(TICKET_TRANSFERRED_TOPIC)) {
            _handleTicketTransfer(topic_1, topic_2, topic_3, data);
        }
        // Handle TicketMinted event
        else if (topic_0 == uint256(TICKET_MINTED_TOPIC)) {
            _handleTicketMinted(topic_1, topic_2, topic_3, data);
        }
        // Handle PriceViolation event
        else if (topic_0 == uint256(PRICE_VIOLATION_TOPIC)) {
            _handlePriceViolation(topic_1, data);
        }
    }
    
    /**
     * @dev Handle ticket transfer events and validate them
     */
    function _handleTicketTransfer(
        uint256 topic_1, // tokenId (indexed)
        uint256 topic_2, // from address (indexed)
        uint256 topic_3, // to address (indexed)
        bytes calldata data
    ) private {
        uint256 tokenId = topic_1;
        address from = address(uint160(topic_2));
        address to = address(uint160(topic_3));
        
        // Decode additional data (transferCount, eventId)
        (uint256 transferCount, uint256 eventId) = abi.decode(data, (uint256, uint256));
        
        // Update internal state
        ticketTransferCounts[tokenId] = transferCount;
        ticketCurrentOwner[tokenId] = to;
        
        // Validate the transfer
        bool isValid = true;
        string memory reason = "Valid transfer";
        
        // Check for suspicious patterns
        if (transferCount > 5) {
            isValid = false;
            reason = "Excessive transfers detected";
            suspiciousTickets[tokenId] = true;
        }
        
        // Check if from/to addresses are suspicious
        // (In production, you'd check against a blacklist)
        
        emit TicketTransferMonitored(tokenId, from, to, transferCount);
        
        // Send callback to destination chain
        _sendValidationCallback(tokenId, from, to, transferCount, eventId, isValid, reason);
    }
    
    /**
     * @dev Handle ticket minting events
     */
    function _handleTicketMinted(
        uint256 topic_1, // tokenId (indexed)
        uint256 topic_2, // eventId (indexed)
        uint256 topic_3, // buyer (indexed)
        bytes calldata /* data */
    ) private {
        uint256 tokenId = topic_1;
        address buyer = address(uint160(topic_3));
        
        // Initialize tracking for new ticket
        ticketTransferCounts[tokenId] = 0;
        ticketCurrentOwner[tokenId] = buyer;
    }
    
    /**
     * @dev Handle price violation events (scalping attempts)
     */
    function _handlePriceViolation(
        uint256 topic_1, // tokenId (indexed)
        bytes calldata data
    ) private {
        uint256 tokenId = topic_1;
        (uint256 attemptedPrice, uint256 maxAllowedPrice) = abi.decode(data, (uint256, uint256));
        
        suspiciousTickets[tokenId] = true;
        address scalper = ticketCurrentOwner[tokenId];
        
        emit ScalpingAttemptDetected(tokenId, scalper);
        
        // Send scalping detection callback
        bytes memory payload = abi.encodeWithSignature(
            "onScalpingDetected(uint256,address,uint256,uint256)",
            tokenId,
            scalper,
            attemptedPrice,
            maxAllowedPrice
        );
        
        emit ReactiveCallback(callbackContract, payload);
        
        // In production, this would trigger a cross-chain callback
        // via the Reactive Network's callback mechanism
    }
    
    /**
     * @dev Send validation result to callback contract on destination chain
     */
    function _sendValidationCallback(
        uint256 _tokenId,
        address _from,
        address _to,
        uint256 _transferCount,
        uint256 _eventId,
        bool _isValid,
        string memory _reason
    ) private {
        
        bytes memory payload = abi.encodeWithSignature(
            "onTransferValidated(uint256,address,address,uint256,uint256,bool,string)",
            _tokenId,
            _from,
            _to,
            _transferCount,
            _eventId,
            _isValid,
            _reason
        );
        
        emit ValidationResultSent(_tokenId, _isValid, _reason);
        emit ReactiveCallback(callbackContract, payload);
        
        // The actual cross-chain callback would be handled by the Reactive Network
        // This is a simplified representation for the MVP
    }
    
    /**
     * @dev Get ticket validation status
     */
    function getTicketStatus(uint256 _tokenId) external view returns (
        uint256 transferCount,
        address currentOwner,
        bool isSuspicious
    ) {
        return (
            ticketTransferCounts[_tokenId],
            ticketCurrentOwner[_tokenId],
            suspiciousTickets[_tokenId]
        );
    }
    
    /**
     * @dev Check if a ticket is suspicious
     */
    function isTicketSuspicious(uint256 _tokenId) external view returns (bool) {
        return suspiciousTickets[_tokenId];
    }
    
    /**
     * @dev Update origin contract address (owner only)
     */
    function updateOriginContract(address _newOrigin) external onlyOwner {
        require(_newOrigin != address(0), "Invalid origin contract");
        originContract = _newOrigin;
    }
    
    /**
     * @dev Update callback contract address (owner only)
     */
    function updateCallbackContract(address _newCallback) external onlyOwner {
        require(_newCallback != address(0), "Invalid callback contract");
        callbackContract = _newCallback;
    }
    
    /**
     * @dev Withdraw contract balance (owner only)
     */
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
    /**
     * @dev Receive ether for gas payments
     */
    receive() external payable {}
}
