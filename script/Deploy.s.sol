// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../src/EventTicket.sol";
import "../src/TicketCallback.sol";
import "../src/TicketReactiveValidator.sol";

/**
 * @title Deploy
 * @dev Deployment script for A10D Event Ticketing System
 * 
 * Usage:
 * 1. Deploy TicketCallback to destination chain
 * 2. Deploy EventTicket to origin chain
 * 3. Deploy TicketReactiveValidator to Reactive Network
 */
contract DeployScript is Script {
    
    function run() external {
        // Load environment variables
        uint256 originPrivateKey = vm.envUint("ORIGIN_PRIVATE_KEY");
        uint256 destinationPrivateKey = vm.envUint("DESTINATION_PRIVATE_KEY");
        uint256 reactivePrivateKey = vm.envUint("REACTIVE_PRIVATE_KEY");
        
        uint256 originChainId = vm.envUint("ORIGIN_CHAIN_ID");
        uint256 destinationChainId = vm.envUint("DESTINATION_CHAIN_ID");
        
        address systemContract = vm.envAddress("SYSTEM_CONTRACT_ADDR");
        address callbackProxyAddr = vm.envAddress("DESTINATION_CALLBACK_PROXY_ADDR");
        
        console.log("=== A10D Event Ticketing Deployment ===");
        console.log("");
        
        // Step 1: Deploy TicketCallback to destination chain
        console.log("Step 1: Deploying TicketCallback to destination chain...");
        vm.createSelectFork(vm.envString("DESTINATION_RPC"));
        vm.startBroadcast(destinationPrivateKey);
        
        TicketCallback callback = new TicketCallback{value: 0.02 ether}(callbackProxyAddr);
        console.log("TicketCallback deployed at:", address(callback));
        
        vm.stopBroadcast();
        
        // Step 2: Deploy EventTicket to origin chain
        console.log("");
        console.log("Step 2: Deploying EventTicket to origin chain...");
        vm.createSelectFork(vm.envString("ORIGIN_RPC"));
        vm.startBroadcast(originPrivateKey);
        
        EventTicket eventTicket = new EventTicket();
        console.log("EventTicket deployed at:", address(eventTicket));
        
        vm.stopBroadcast();
        
        // Step 3: Deploy TicketReactiveValidator to Reactive Network
        console.log("");
        console.log("Step 3: Deploying TicketReactiveValidator to Reactive Network...");
        vm.createSelectFork(vm.envString("REACTIVE_RPC"));
        vm.startBroadcast(reactivePrivateKey);
        
        TicketReactiveValidator reactive = new TicketReactiveValidator{value: 0.1 ether}(
            systemContract,
            originChainId,
            destinationChainId,
            address(eventTicket),
            address(callback)
        );
        console.log("TicketReactiveValidator deployed at:", address(reactive));
        
        vm.stopBroadcast();
        
        // Summary
        console.log("");
        console.log("=== Deployment Summary ===");
        console.log("Origin Chain (ID:", originChainId, ")");
        console.log("  EventTicket:", address(eventTicket));
        console.log("");
        console.log("Destination Chain (ID:", destinationChainId, ")");
        console.log("  TicketCallback:", address(callback));
        console.log("");
        console.log("Reactive Network:");
        console.log("  TicketReactiveValidator:", address(reactive));
        console.log("");
        console.log("Save these addresses to your .env file!");
    }
}

/**
 * @title DeployEventTicket
 * @dev Deploy only EventTicket contract to origin chain
 */
contract DeployEventTicketScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("ORIGIN_PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        EventTicket eventTicket = new EventTicket();
        console.log("EventTicket deployed at:", address(eventTicket));
        
        vm.stopBroadcast();
    }
}

/**
 * @title DeployTicketCallback
 * @dev Deploy only TicketCallback contract to destination chain
 */
contract DeployTicketCallbackScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DESTINATION_PRIVATE_KEY");
        address callbackProxy = vm.envAddress("DESTINATION_CALLBACK_PROXY_ADDR");
        
        vm.startBroadcast(deployerPrivateKey);
        
        TicketCallback callback = new TicketCallback{value: 0.02 ether}(callbackProxy);
        console.log("TicketCallback deployed at:", address(callback));
        
        vm.stopBroadcast();
    }
}

/**
 * @title DeployReactive
 * @dev Deploy only TicketReactiveValidator to Reactive Network
 */
contract DeployReactiveScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("REACTIVE_PRIVATE_KEY");
        
        address systemContract = vm.envAddress("SYSTEM_CONTRACT_ADDR");
        uint256 originChainId = vm.envUint("ORIGIN_CHAIN_ID");
        uint256 destinationChainId = vm.envUint("DESTINATION_CHAIN_ID");
        address originContract = vm.envAddress("EVENT_TICKET_ADDR");
        address callbackContract = vm.envAddress("TICKET_CALLBACK_ADDR");
        
        vm.startBroadcast(deployerPrivateKey);
        
        TicketReactiveValidator reactive = new TicketReactiveValidator{value: 0.1 ether}(
            systemContract,
            originChainId,
            destinationChainId,
            originContract,
            callbackContract
        );
        console.log("TicketReactiveValidator deployed at:", address(reactive));
        
        vm.stopBroadcast();
    }
}
