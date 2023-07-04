// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract WrappedToken is ERC20, ERC20Burnable {
    IERC20 public immutable token;

    constructor(address tokenAddress) ERC20("Wrapped Token", "WTKN") {
        token = IERC20(tokenAddress);
    }

    function deposit(uint amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    function withdraw(uint amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
        token.transfer(msg.sender, amount);
    }
}