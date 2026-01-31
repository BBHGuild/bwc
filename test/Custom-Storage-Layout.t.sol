// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {Test, console} from "forge-std/Test.sol";

uint256 constant OFFSET = 0x10 + 1;

contract CustomStorageLayoutA {

    uint256 public A = 55;

}

contract CustomStorageLayoutB layout at 0xAA + OFFSET is CustomStorageLayoutA {

    uint256 public B = 65;

}

contract CustomStorageLayoutTest is Test {

    CustomStorageLayoutB csl;

    function setUp() public {
        csl = new CustomStorageLayoutB();
    }

    function test_Storage_Slot() public view {
        bytes32 slotA = vm.load(address(csl), bytes32(uint256(0xAA + OFFSET)));
        bytes32 slotB = vm.load(address(csl), bytes32(uint256(0xAA + OFFSET + 0x01)));
        console.log("slotA %d", uint256(slotA));
        console.log("slotB %d", uint256(slotB));
    }

}
