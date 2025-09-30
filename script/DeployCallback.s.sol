// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {TicketCallback} from "../src/TicketCallback.sol";

contract DeployCallback is Script {
    function run() external returns (TicketCallback) {
        address callbackProxy = vm.envAddress("DESTINATION_CALLBACK_PROXY_ADDR");
        
        vm.startBroadcast();
        
        console.log("Deploying TicketCallback with proxy:", callbackProxy);
        TicketCallback callback = new TicketCallback(callbackProxy);
        console.log("TicketCallback deployed to:", address(callback));
        
        vm.stopBroadcast();
        
        return callback;
    }
}
