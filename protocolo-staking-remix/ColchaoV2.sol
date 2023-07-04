// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ILPToken.sol";

contract ColchaoV2 is ReentrancyGuard {

    IERC20 public token;
    ILPToken public lpToken;

    mapping(address => uint) public checkpoints; //user => deposit block number

    uint public rewardPerBlock = 1;

    constructor(address tokenAddress, address lpTokenAddress){
        token = IERC20(tokenAddress);
        lpToken = ILPToken(lpTokenAddress);
    }

    function rewardPayment(uint depositAmount) internal {
        uint rewards = calculateRewards();
        if(rewards > 0 || depositAmount > 0)
            lpToken.mint(msg.sender, rewards + depositAmount);
        
        checkpoints[msg.sender] = block.number;
    }

    function deposit(uint amount) external nonReentrant {
        token.transferFrom(msg.sender, address(this), amount);

        if(checkpoints[msg.sender] == 0){
            checkpoints[msg.sender] = block.number;
            lpToken.mint(msg.sender, amount);//emite os tokens de garantia
        }
        else rewardPayment(amount);//paga o que deve a ele até aqui em recompensas + o novo depósito
    }

    function withdraw(uint amount) external nonReentrant {
        require(lpToken.balanceOf(msg.sender) >= amount, "Insufficient funds");
        
        rewardPayment(0);//paga as últimas recompensas devidas, faz antes das demais funções para ter o saldo original

        lpToken.burn(msg.sender, amount);
        token.transfer(msg.sender, amount);
    }

    function calculateRewards() public view returns (uint) {
        uint blocks = block.number - checkpoints[msg.sender];
        return (lpToken.balanceOf(msg.sender) / 10000) * blocks * rewardPerBlock;
    }

    function liquidityPool() external view returns(uint) {
        return token.balanceOf(address(this));
    }
}