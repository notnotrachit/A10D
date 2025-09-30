// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IReactive
 * @dev Interface for Reactive Smart Contracts
 * Based on Reactive Network documentation
 */
interface IReactive {
    /**
     * @dev Main reactive function called when subscribed events occur
     * @param chain_id The chain ID where the event originated
     * @param _contract The contract address that emitted the event
     * @param topic_0 The event signature (first topic)
     * @param topic_1 First indexed parameter
     * @param topic_2 Second indexed parameter
     * @param topic_3 Third indexed parameter
     * @param data Non-indexed event data
     * @param block_number Block number where event occurred
     * @param op_code Operation code
     */
    function react(
        uint256 chain_id,
        address _contract,
        uint256 topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3,
        bytes calldata data,
        uint256 block_number,
        uint256 op_code
    ) external;
}
