// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {HelloWorld} from "./HelloWorld.sol";
import {Test} from "forge-std/Test.sol";

// Solidity tests are compatible with foundry, so they
// use the same syntax and offer the same functionality.

contract HelloWorldTest is Test {
  HelloWorld helloWorld;

  function setUp() public {
    helloWorld = new HelloWorld();
  }

  function test_HelloWorld() public view {
    bytes32 expected = keccak256(bytes("Hello World!"));
    bytes32 actual = keccak256(bytes(helloWorld.helloWorld()));
    require(actual == expected, "Should be Hello World!");
  }
}
