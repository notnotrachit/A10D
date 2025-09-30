// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title TicketCallback
 * @dev Receives callbacks from Reactive Network about ticket transfers and validations
 * Deployed on destination chain (e.g., Sepolia)
 */
contract TicketCallback {
    
    address public callbackSender;
    address public owner;
    
    // Validation records
    struct TransferValidation {
        uint256 tokenId;
        address from;
        address to;
        uint256 transferCount;
        uint256 timestamp;
        bool isValid;
        string reason;
    }
    
    mapping(uint256 => TransferValidation[]) public transferHistory;
    mapping(uint256 => bool) public flaggedTickets;
    mapping(address => bool) public blacklistedAddresses;
    mapping(uint256 => uint256) public suspiciousActivityCount;
    
    // Events
    event TransferValidated(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to,
        bool isValid,
        string reason
    );
    event TicketFlagged(uint256 indexed tokenId, string reason);
    event AddressBlacklisted(address indexed account, string reason);
    event ScalpingDetected(uint256 indexed tokenId, address indexed scalper);
    event CallbackReceived(uint256 indexed tokenId, bytes data);
    
    modifier onlyCallbackSender() {
        require(msg.sender == callbackSender, "Only callback sender can call");
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }
    
    constructor(address _callbackSender) payable {
        require(_callbackSender != address(0), "Invalid callback sender");
        callbackSender = _callbackSender;
        owner = msg.sender;
    }
    
    /**
     * @dev Receive and process transfer validation from Reactive Network
     */
    function onTransferValidated(
        uint256 _tokenId,
        address _from,
        address _to,
        uint256 _transferCount,
        uint256 _eventId,
        bool _isValid,
        string calldata _reason
    ) external onlyCallbackSender {
        
        TransferValidation memory validation = TransferValidation({
            tokenId: _tokenId,
            from: _from,
            to: _to,
            transferCount: _transferCount,
            timestamp: block.timestamp,
            isValid: _isValid,
            reason: _reason
        });
        
        transferHistory[_tokenId].push(validation);
        
        // Flag suspicious tickets
        if (!_isValid) {
            flaggedTickets[_tokenId] = true;
            suspiciousActivityCount[_tokenId]++;
            
            emit TicketFlagged(_tokenId, _reason);
            
            // Blacklist addresses involved in repeated violations
            if (suspiciousActivityCount[_tokenId] >= 3) {
                blacklistedAddresses[_from] = true;
                blacklistedAddresses[_to] = true;
                emit AddressBlacklisted(_from, "Repeated violations");
                emit AddressBlacklisted(_to, "Repeated violations");
            }
        }
        
        emit TransferValidated(_tokenId, _from, _to, _isValid, _reason);
    }
    
    /**
     * @dev Receive scalping detection notification
     */
    function onScalpingDetected(
        uint256 _tokenId,
        address _scalper,
        uint256 _attemptedPrice,
        uint256 _maxAllowedPrice
    ) external onlyCallbackSender {
        
        flaggedTickets[_tokenId] = true;
        blacklistedAddresses[_scalper] = true;
        suspiciousActivityCount[_tokenId]++;
        
        emit ScalpingDetected(_tokenId, _scalper);
        emit AddressBlacklisted(_scalper, "Price gouging detected");
    }
    
    /**
     * @dev Generic callback receiver
     */
    function reactiveCallback(
        uint256 _chainId,
        address _contract,
        uint256 _topic0,
        bytes calldata _data
    ) external onlyCallbackSender {
        // Decode the data based on topic
        // Topic0 corresponds to the event signature being monitored
        
        emit CallbackReceived(_topic0, _data);
    }
    
    /**
     * @dev Check if a ticket is flagged
     */
    function isTicketFlagged(uint256 _tokenId) external view returns (bool) {
        return flaggedTickets[_tokenId];
    }
    
    /**
     * @dev Check if an address is blacklisted
     */
    function isAddressBlacklisted(address _account) external view returns (bool) {
        return blacklistedAddresses[_account];
    }
    
    /**
     * @dev Get transfer history for a ticket
     */
    function getTransferHistory(uint256 _tokenId) external view returns (TransferValidation[] memory) {
        return transferHistory[_tokenId];
    }
    
    /**
     * @dev Get suspicious activity count for a ticket
     */
    function getSuspiciousActivityCount(uint256 _tokenId) external view returns (uint256) {
        return suspiciousActivityCount[_tokenId];
    }
    
    /**
     * @dev Manually flag a ticket (owner only)
     */
    function flagTicket(uint256 _tokenId, string calldata _reason) external onlyOwner {
        flaggedTickets[_tokenId] = true;
        emit TicketFlagged(_tokenId, _reason);
    }
    
    /**
     * @dev Manually blacklist an address (owner only)
     */
    function blacklistAddress(address _account, string calldata _reason) external onlyOwner {
        blacklistedAddresses[_account] = true;
        emit AddressBlacklisted(_account, _reason);
    }
    
    /**
     * @dev Remove address from blacklist (owner only)
     */
    function removeFromBlacklist(address _account) external onlyOwner {
        blacklistedAddresses[_account] = false;
    }
    
    /**
     * @dev Unflag a ticket (owner only)
     */
    function unflagTicket(uint256 _tokenId) external onlyOwner {
        flaggedTickets[_tokenId] = false;
    }
    
    /**
     * @dev Update callback sender (owner only)
     */
    function updateCallbackSender(address _newSender) external onlyOwner {
        require(_newSender != address(0), "Invalid callback sender");
        callbackSender = _newSender;
    }
    
    /**
     * @dev Withdraw contract balance (owner only)
     */
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
    /**
     * @dev Receive ether
     */
    receive() external payable {}
}
