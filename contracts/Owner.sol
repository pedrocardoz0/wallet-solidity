// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Owner {
    address public owner;

    modifier OnlyOnwer() {
        require(msg.sender == owner, "You must be the owner");
        _;
    }
}
