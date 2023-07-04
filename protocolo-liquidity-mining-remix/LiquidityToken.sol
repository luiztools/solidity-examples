// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ILPToken.sol";

contract LiquidityToken is ILPToken, ERC20 {

    address immutable owner;
    address public liquidityMining;

    constructor() ERC20("LiquidityToken", "LQT") {
        owner = msg.sender;
    }

    function setLiquidityMining(address _liquidityMining){
        require(msg.sender == owner, "Unauthorized");
        liquidityMining = _liquidityMining;
    }


    function mint(address receiver, uint amount) external{
        require(msg.sender == owner || msg.sender == liquidityMining, "Unauthorized");
        _mint(receiver, amount);
    }
}