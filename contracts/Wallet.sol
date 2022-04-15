// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./Owner.sol";

contract Wallet is Owner {
    mapping(address => Balance) public balance;

    constructor() {
        owner = msg.sender;
    }

    struct Balance {
        uint256 balance;
        uint256 allowedWithdraw;
        mapping(uint256 => Transaction) transaction;
        uint256 numTransactions;
        mapping(uint256 => Order) order;
        uint256 numOrders;
    }

    struct Transaction {
        uint256 timestamp;
        uint256 amount;
        address to;
    }

    struct Order {
        bool approved;
        bool rejected;
        bool blocked;
        uint256 amount;
    }

    function withdraw(uint256 _amount, address _to) public {}

    function createOrder(uint256 _amount) public {}

    function deposit(uint256 _amount) public payable {}

    receive() external payable {
        uint256 transactionId = balance[msg.sender].numTransactions + 1;

        Transaction memory newTransaction = Transaction({
            timestamp: block.timestamp,
            amount: msg.value,
            to: msg.sender
        });

        balance[msg.sender].balance = msg.value;
        balance[msg.sender].transaction[transactionId] = newTransaction;
    }

    function withdrawFromUser(
        uint256 _amount,
        address _from,
        address _to
    ) public OnlyOnwer {}

    function approveOrder(uint256 _order, address payable _from)
        public
        OnlyOnwer
    {}

    function rejectOrder(uint256 _order, address payable _from)
        public
        OnlyOnwer
    {}

    function openOrdersFromUser(address _from) public OnlyOnwer {}

    /*
        Debug.
    */
    function getBalance() public view returns (uint256) {
        return balance[msg.sender].balance;
    }

    function getTransactions(uint256 _id)
        public
        view
        returns (uint256, address)
    {
        Balance storage callerBalance = balance[msg.sender];
        Transaction memory transactionId = callerBalance.transaction[_id];

        return (transactionId.amount, transactionId.to);
    }
}
