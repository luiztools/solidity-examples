// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract ValidacaoXModifier {
    address admin = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint x = 0;
    error CustomError();

    function testValidacao() external {
        if (msg.sender != admin) revert CustomError();
        x = 10;
    }

    modifier isAdmin(){
        if (msg.sender != admin) revert CustomError();
        _;
    }

    function testModifier() external isAdmin() {
        x = 10;
    }
}
