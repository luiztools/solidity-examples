// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

struct Transfer {
    address author;
    address to;
    uint amount;
    address closedBy;
    bool sent;
    uint startTimestamp;
    uint endTimestamp;
}

contract MultiSigWallet {
    //start of administrative scope
    mapping(address => bool) public owners;
    uint public ownersQty;

    constructor() {
        owners[msg.sender] = true;
        ownersQty++;
    }

    modifier onlyOwner() {
        require(owners[msg.sender] == true, "Not an owner");
        _;
    }

    function addOwner(address newOwner) public onlyOwner {
        require(ownersQty < 3, "You cannot have more than 3 owners");
        require(!owners[newOwner], "This address already is an owner");
        owners[newOwner] = true;
        ownersQty++;
    }

    function removeOwner(address oldOwner) public onlyOwner {
        require(ownersQty > 2, "You cannot have less than 2 owners");
        require(owners[oldOwner], "This address is not an owner");
        owners[oldOwner] = false;
        ownersQty--;
    }
    //end of administrative scope

    //start of transfer scope
    uint public nextTransferId = 1;
    mapping(uint => Transfer) public transfers;
    uint public lockedBalance = 0;

    event TransferReceived(address indexed from, uint amount);
    event TransferStart(uint indexed transferId, address indexed author, address indexed to, uint amount);
    event TransferApprove(uint indexed transferId, address indexed approvedBy, address indexed to, uint amount);
    event TransferDenial(uint indexed transferId, address indexed deniedBy, address indexed to);

    function startTransfer(address payable to, uint amount) public onlyOwner {
        require(amount <= address(this).balance - lockedBalance, "Insufficient balance");

        Transfer memory transfer = Transfer({
            author: msg.sender,
            to: to,
            amount: amount,
            closedBy: address(0),
            sent: false,
            startTimestamp: block.timestamp,
            endTimestamp: 0
        });

        transfers[nextTransferId] = transfer;
        lockedBalance += amount;
        emit TransferStart(nextTransferId, msg.sender, to, amount);
        nextTransferId++;
    }

    function endTransfer(uint transferId, bool send) public onlyOwner {
        Transfer memory transfer = transfers[transferId];
        require(transfer.closedBy == address(0), "Already closed");

        if (send) {
            require(transfer.author != msg.sender, "Cannot approve himself");
            require(transfer.amount <= address(this).balance,"Insufficient balance");
        }

        transfer.closedBy = msg.sender;
        transfer.endTimestamp = block.timestamp;
        transfer.sent = send;
        transfers[transferId] = transfer;
        lockedBalance -= transfer.amount;

        if (send)
            emit TransferApprove(transferId, msg.sender, transfer.to, transfer.amount);
        else emit TransferDenial(transferId, msg.sender, transfer.to);

        payable(transfer.to).transfer(transfer.amount);
    }
    //end of transfer scope

    receive() external payable {
        emit TransferReceived(msg.sender, msg.value);
    }
}
