// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./IStableCoin.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyExchange is Ownable {

    uint public fee = 20;//0.20%
    IStableCoin private immutable stableCoin;

    constructor(address _stableCoin) {
        stableCoin = IStableCoin(_stableCoin);
    }

    function setFee(uint _fee) external onlyOwner {
        fee = _fee;
    }

    function deposit(address customer, uint amount) external onlyOwner {
        uint amountWithFee = (amount * (10000 - fee)) / 10000;
        stableCoin.mint(customer, amountWithFee);
    }

    function withdraw(address customer, uint amount) external onlyOwner {
        stableCoin.burn(customer, amount);
    }

}