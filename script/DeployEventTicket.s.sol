// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {EventTicket} from "../src/EventTicket.sol";

contract DeployEventTicket is Script {
    function run() external returns (EventTicket) {
        vm.startBroadcast();
        
        console.log("Deploying EventTicket...");
        EventTicket ticket = new EventTicket();
        console.log("EventTicket deployed to:", address(ticket));
        
        vm.stopBroadcast();
        
        return ticket;
    }
}
