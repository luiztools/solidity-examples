// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract AcessControl {
    enum Role {
        NONE,
        OWNER,
        MANAGER,
        CUSTOMER
    }

    mapping(address => Role) private _roles;

    constructor(){
        _roles[msg.sender] = Role.OWNER;
    }

    modifier onlyRole(Role role) {
        require(_roles[msg.sender] == role, "You do not have permission");
        _;
    }

    function setRole(Role role, address account) public onlyRole(Role.OWNER) {
        if (_roles[account] !=  role) {
            _roles[account] = role;
        }
    }
}

contract AcessControlContract is AcessControl {
    string internal message = "Hello World!";

    function getMessage() public view returns (string memory) {
        return message;
    }

    function setMessage(string calldata newMessage) external onlyRole(Role.MANAGER) {
        message = newMessage;
    }
}
