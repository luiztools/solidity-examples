// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {HelloWorld} from "../src/HelloWorld.sol";

contract HelloWorldTest is Test {
    HelloWorld helloWorld;

    function setUp() public {
        helloWorld = new HelloWorld();
    }

    function test_HelloWorld() public view {
        string memory expected = "Hello World!";
        string memory actual = helloWorld.helloWorld();
        assertEq(expected, actual);
    }
}
