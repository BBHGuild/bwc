// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

contract Counter {

    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }

}

/// @notice replicate legacy selfdestruct functionality
contract CounterDestroyed {

    constructor() {
        setNumber(1);
        increment();
    }

    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
        selfdestruct(payable(msg.sender));
    }

}

contract CounterScript is Script {

    // Counter public counter;
    CounterDestroyed public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        counter = new CounterDestroyed();
        vm.stopBroadcast();
    }

}
