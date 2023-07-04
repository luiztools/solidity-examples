// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ILPToken.sol";

contract LiquidityMining is ReentrancyGuard {
    IERC20 public token;
    ILPToken public reward;

    mapping(address => uint) public balances; //user => balance
    mapping(address => uint) public checkpoints; //user => deposit block number

    uint public rewardPerBlock = 1;

    constructor(address tokenAddress, address rewardAddress) {
        token = IERC20(tokenAddress);
        reward = ILPToken(rewardAddress);
    }

    function rewardPayment(uint balance) internal {
        uint difference = block.number - checkpoints[msg.sender];
        if (difference > 0) {
            reward.mint(balance * difference * rewardPerBlock, msg.sender);
            checkpoints[msg.sender] = block.number;
        }
    }

    function deposit(uint amount) external nonReentrant {
        token.transferFrom(msg.sender, address(this), amount);
        uint originalBalance = balances[msg.sender]; //necessário para recompensas
        balances[msg.sender] += amount;

        if (checkpoints[msg.sender] == 0) {
            checkpoints[msg.sender] = block.number;
        } else rewardPayment(originalBalance); //paga o que deve a ele até aqui
    }

    function withdraw(uint amount) external nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient funds");
        uint originalBalance = balances[msg.sender]; //necessário para recompensas
        balances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
        rewardPayment(originalBalance); //paga as últimas recompensas devidas
    }

    function calculateRewards() external view returns (uint) {
        uint difference = block.number - checkpoints[msg.sender];
        return balances[msg.sender] * difference * rewardPerBlock;
    }

    function liquidityPool() external pure returns (uint) {
        return token.balanceOf(address(this));
    }
}
