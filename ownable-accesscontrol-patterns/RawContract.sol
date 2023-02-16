// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract RawContract {
    string internal message = "Hello World!";

    function getMessage() public view returns (string memory) {
        return message;
    }

    function setMessage(string calldata newMessage) external {
        message = newMessage;
    }
}
