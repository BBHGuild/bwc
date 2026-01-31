// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";

contract MulService {

    uint256 transient multiplier;

    function setMultiplier(uint256 mul) external {
        multiplier = mul;
    }

    function multiply(uint256 value) external view returns (uint256) {
        return value * multiplier;
    }

}

contract MulServiceTest is Test {

    MulService service;

    function setUp() public {
        service = new MulService();
    }

    function testMultiply() public {
        service.setMultiplier(2);
        uint256 result = service.multiply(3);
        console.log("result: ", result);
        assertEq(result, 6);
    }

}
