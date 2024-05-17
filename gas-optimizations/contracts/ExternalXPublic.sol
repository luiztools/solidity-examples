// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ExternalXPublic {
    uint x = 0;

    function testExternal() external {
        x = 1;
    }

    function testPublic() public {
        x = 1;
    }
}
