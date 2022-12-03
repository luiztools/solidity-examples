// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./IContrato.sol";

contract Contrato is IContrato {
    string private result = "";

    function getResult() external view returns (string memory) {
        return result;
    }
}
