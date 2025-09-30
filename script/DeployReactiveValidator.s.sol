// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {TicketReactiveValidator} from "../src/TicketReactiveValidator.sol";

contract DeployReactiveValidator is Script {
    function run() external returns (TicketReactiveValidator) {
        address systemContract = vm.envAddress("SYSTEM_CONTRACT_ADDR");
        uint256 originChainId = vm.envUint("ORIGIN_CHAIN_ID");
        uint256 destinationChainId = vm.envUint("DESTINATION_CHAIN_ID");
        address ticketAddr = vm.envAddress("EVENT_TICKET_ADDR");
        address callbackAddr = vm.envAddress("TICKET_CALLBACK_ADDR");
        
        vm.startBroadcast();
        
        console.log("Deploying TicketReactiveValidator...");
        console.log("  System Contract:", systemContract);
        console.log("  Origin Chain ID:", originChainId);
        console.log("  Destination Chain ID:", destinationChainId);
        console.log("  EventTicket:", ticketAddr);
        console.log("  TicketCallback:", callbackAddr);
        
        TicketReactiveValidator validator = new TicketReactiveValidator{value: 0.05 ether}(
            systemContract,
            originChainId,
            destinationChainId,
            ticketAddr,
            callbackAddr
        );
        
        console.log("TicketReactiveValidator deployed to:", address(validator));
        
        vm.stopBroadcast();
        
        return validator;
    }
}
