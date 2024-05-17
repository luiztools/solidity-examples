// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract StorageXMemoryXCalldata {
    string x = "";

    function testMemory(string memory text) external {
        x = text;
    }

    function testCalldata(string calldata text) external {
        x = text;
    }

    uint y = 0;

    function testArrayMemory(uint[] memory numbers) external {
        y = numbers[numbers.length - 1];
    }

    function testArrayCalldata(uint[] calldata numbers) external {
        y = numbers[numbers.length - 1];
    }
}
