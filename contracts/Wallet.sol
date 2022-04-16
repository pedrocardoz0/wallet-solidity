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

    function withdraw(uint256 _amount, address _to) public {
        Balance storage userBalance = balance[msg.sender];
        require(userBalance.balance > 0, "Cant Withdraw");
        require(
            ((userBalance.balance <= userBalance.allowedWithdraw) ||
                msg.sender == owner),
            "Cant Withdraw - Overlap allowed"
        );

        uint256 transactionId = userBalance.numTransactions + 1;

        Transaction memory newTransaction = Transaction({
            timestamp: block.timestamp,
            amount: _amount,
            to: _to
        });

        if (msg.sender != owner) {
            userBalance.allowedWithdraw -= _amount;
        }

        userBalance.balance -= _amount;
        userBalance.transaction[transactionId] = newTransaction;
        userBalance.numTransactions = transactionId;

        payable(_to).transfer(_amount);
    }

    function createOrder(uint256 _amount) public {
        Balance storage userBalance = balance[msg.sender];
        uint256 orderId = userBalance.numOrders + 1;

        require(msg.sender != owner, "Only users");
        require(
            userBalance.balance >= _amount,
            "Cant withdraw more than the balance"
        );

        Order memory newOrder = Order({
            approved: false,
            rejected: false,
            blocked: false,
            amount: _amount
        });

        userBalance.numOrders = orderId;
        userBalance.order[orderId] = newOrder;
    }

    function deposit(address _to) public payable {
        Balance storage userBalance = balance[_to];
        userBalance.balance += msg.value;
    }

    receive() external payable {
        uint256 transactionId = balance[msg.sender].numTransactions + 1;

        Transaction memory newTransaction = Transaction({
            timestamp: block.timestamp,
            amount: msg.value,
            to: msg.sender
        });

        balance[msg.sender].balance += msg.value;
        balance[msg.sender].numTransactions = transactionId;
        balance[msg.sender].transaction[transactionId] = newTransaction;
    }

    function withdrawFromUser(
        uint256 _amount,
        address _from,
        address _to
    ) public OnlyOnwer {
        Balance storage userFromBalance = balance[_from];
        Balance storage userToBalance = balance[_to];

        require(userFromBalance.balance >= _amount, "Cant withdraw");

        userFromBalance.balance -= _amount;
        userToBalance.balance += _amount;
    }

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

    function getOrders(uint256 _id) public view returns (uint256) {
        Balance storage callerBalance = balance[msg.sender];
        Order memory orderId = callerBalance.order[_id];

        return orderId.amount;
    }
}
