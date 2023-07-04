// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ILPToken.sol";

contract ColchaoV2 is ReentrancyGuard {
    IERC20 public token;
    ILPToken public lpToken;

    mapping(address => uint) public checkpoints; //user => deposit date

    uint public rewardPerPeriod = 1;
    uint public duration = 30 * 24 * 60 * 60; //30 dias

    constructor(address tokenAddress, address lpTokenAddress) {
        token = IERC20(tokenAddress);
        lpToken = ILPToken(lpTokenAddress);
    }

    function rewardPayment(uint depositAmount) internal {
        uint rewards = calculateRewards();
        if (rewards > 0 || depositAmount > 0)
            lpToken.mint(msg.sender, rewards + depositAmount);

        checkpoints[msg.sender] = block.timestamp;
    }

    function deposit(uint amount) external nonReentrant {
        token.transferFrom(msg.sender, address(this), amount);

        if (checkpoints[msg.sender] == 0) {
            checkpoints[msg.sender] = block.timestamp;
            lpToken.mint(msg.sender, amount); //emite os tokens de garantia
        } else rewardPayment(amount); //paga o que deve a ele até aqui em recompensas + o novo depósito
    }

    function canWithdraw() public view returns (bool) {
        return block.timestamp >= depositDate[msg.sender] + duration;
    }

    function withdraw(uint amount) external nonReentrant {
        require(canWithdraw(), "Locked funds");
        require(lpToken.balanceOf(msg.sender) >= amount, "Insufficient funds");

        rewardPayment(0); //paga as últimas recompensas devidas, faz antes das demais funções para ter o saldo original

        lpToken.burn(msg.sender, amount);
        token.transfer(msg.sender, amount);
    }

    function calculateRewards() public view returns (uint) {
        uint months = (block.timestamp - checkpoints[msg.sender]) / duration;
        return (lpToken.balanceOf(msg.sender) / 100) * months * rewardPerPeriod;
    }

    function liquidityPool() external view returns (uint) {
        return token.balanceOf(address(this));
    }
}
