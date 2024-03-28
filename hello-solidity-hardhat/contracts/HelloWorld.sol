// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract HelloWorld {
    string public message = "Hello World!";

    function helloWorld() public view returns (string memory) {
        return message;
    }
}
