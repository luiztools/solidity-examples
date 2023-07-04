// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ILPToken.sol";

contract LiquidityProviderToken is ILPToken, ERC20, ERC20Burnable, Ownable {
    address public protocolContract;

    constructor() ERC20("LiquidityProviderToken", "LPT") { }

    function setProtocol(address _protocolContract) public {
        require(msg.sender == owner(), "Unauthorized");
        protocolContract = _protocolContract;
    }

    function mint(address receiver, uint amount) external {
        require(
            msg.sender == owner() || msg.sender == protocolContract,
            "Unauthorized"
        );
        _mint(receiver, amount);
    }

    function burn(address from, uint amount) external {
        require(
            msg.sender == owner() || msg.sender == protocolContract,
            "Unauthorized"
        );
        _burn(from, amount);
    }
}