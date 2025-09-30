// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../src/EventTicket.sol";
import "../src/TicketCallback.sol";
import "../src/TicketReactiveValidator.sol";

contract DeployAll is Script {
    function run() external {
        // Load environment variables
        address destinationCallbackProxy = vm.envAddress("DESTINATION_CALLBACK_PROXY_ADDR");
        address systemContract = vm.envAddress("SYSTEM_CONTRACT_ADDR");
        uint256 originChainId = vm.envUint("ORIGIN_CHAIN_ID");
        uint256 destinationChainId = vm.envUint("DESTINATION_CHAIN_ID");
        
        uint256 deployerPrivateKey = vm.envUint("DESTINATION_PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy TicketCallback to destination chain
        console.log("Deploying TicketCallback...");
        TicketCallback callback = new TicketCallback(destinationCallbackProxy);
        console.log("TicketCallback deployed at:", address(callback));
        
        vm.stopBroadcast();
    }
}
