// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {HelloWorld} from "../src/HelloWorld.sol";

contract HelloWorldScript is Script {
    HelloWorld public instance;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        instance = new HelloWorld();

        vm.stopBroadcast();
    }
}
