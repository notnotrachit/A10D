// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {TicketReactiveValidatorSimple} from "../src/TicketReactiveValidatorSimple.sol";

contract DeployReactiveSimple is Script {
    function run() external returns (TicketReactiveValidatorSimple) {
        address systemContract = vm.envAddress("SYSTEM_CONTRACT_ADDR");
        uint256 originChainId = vm.envUint("ORIGIN_CHAIN_ID");
        uint256 destinationChainId = vm.envUint("DESTINATION_CHAIN_ID");
        address ticketAddr = vm.envAddress("EVENT_TICKET_ADDR");
        address callbackAddr = vm.envAddress("TICKET_CALLBACK_ADDR");
        
        vm.startBroadcast();
        
        console.log("Deploying TicketReactiveValidatorSimple (no auto-subscribe)...");
        console.log("  System Contract:", systemContract);
        console.log("  Origin Chain ID:", originChainId);
        console.log("  Destination Chain ID:", destinationChainId);
        console.log("  EventTicket:", ticketAddr);
        console.log("  TicketCallback:", callbackAddr);
        
        TicketReactiveValidatorSimple validator = new TicketReactiveValidatorSimple{value: 0.05 ether}(
            systemContract,
            originChainId,
            destinationChainId,
            ticketAddr,
            callbackAddr
        );
        
        console.log("TicketReactiveValidatorSimple deployed to:", address(validator));
        console.log("");
        console.log("IMPORTANT: Call subscribeToEvents() after deployment:");
        console.log("  cast send", address(validator), "subscribeToEvents()");
        console.log("  --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY");
        
        vm.stopBroadcast();
        
        return validator;
    }
}
