// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Reactive Network wildcard constants
uint256 constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;

/**
 * @title ISubscriptionService
 * @dev Interface for Reactive Network subscription service
 * Based on Reactive Network documentation
 */
interface ISubscriptionService {
    /**
     * @dev Subscribe to events from a specific contract
     * @param chain_id The chain ID to monitor
     * @param _contract The contract address to monitor
     * @param topic_0 Event signature to monitor (or REACTIVE_IGNORE for all)
     * @param topic_1 First indexed parameter to filter (or REACTIVE_IGNORE)
     * @param topic_2 Second indexed parameter to filter (or REACTIVE_IGNORE)
     * @param topic_3 Third indexed parameter to filter (or REACTIVE_IGNORE)
     */
    function subscribe(
        uint256 chain_id,
        address _contract,
        uint256 topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3
    ) external;

    /**
     * @dev Unsubscribe from events
     * @param chain_id The chain ID
     * @param _contract The contract address
     * @param topic_0 Event signature
     * @param topic_1 First indexed parameter
     * @param topic_2 Second indexed parameter
     * @param topic_3 Third indexed parameter
     */
    function unsubscribe(
        uint256 chain_id,
        address _contract,
        uint256 topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3
    ) external;
}
