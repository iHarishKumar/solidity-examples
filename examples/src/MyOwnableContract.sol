// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract MyOwnableContract is Ownable2Step {
    string public message;

    constructor() Ownable(msg.sender) {
        message = "Hello, world!";
    }

    function setMessage(string calldata _message) external onlyOwner {
        message = _message;
    }
}
