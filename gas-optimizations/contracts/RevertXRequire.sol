// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract RevertXRequire {
    uint x = 0;

    function testRequire(uint number) public {
        require(number < 10, "CustomError");
        x = 1;
    }

    function testRevert(uint number) external {
        if(number > 10)
            revert("CustomError");

        x = 1;
    }

    error CustomError();
    function testRevertCustom(uint number) external {
        if(number > 10)
            revert CustomError();

        x = 1;
    }
}
