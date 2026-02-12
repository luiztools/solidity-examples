// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {BookDatabase} from "../src/BookDatabase.sol";

contract BookDatabaseScript is Script {
    BookDatabase public instance;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        instance = new BookDatabase();

        vm.stopBroadcast();
    }
}
