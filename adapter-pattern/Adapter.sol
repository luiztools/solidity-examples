// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./IContrato.sol";

contract Adapter {
    IContrato private contrato;
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function getResult() external view returns (string memory) {
        return contrato.getResult();
    }

    function upgrade(address newImplementation) external {
        require(msg.sender == owner, "You do not have permission");
        contrato = IContrato(newImplementation);
    }
}
